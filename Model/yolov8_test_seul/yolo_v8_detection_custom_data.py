# 사람만 탐지하기, 20초 이상 탐지 조건


import cv2
from ultralytics import YOLO
import numpy as np
from time import time

from ultralytics.utils.checks import check_imshow   # 이미지 표시를 지원 (시각화 목적)
from ultralytics.utils.plotting import Annotator, colors    # 이미지나 비디오에서 객체를 주석 처리하고 시각화

from collections import defaultdict

from datetime import datetime  # 파일명에 시간을 추가하기 위한 datetime 라이브러리
import os  # 폴더 생성을 위해 추가
import re

# Load the YOLOv8 model
model = YOLO('yolov8n.pt')

# 객체 추적과 관련된 변수 초기화
track_history = defaultdict(lambda: [])   # 추적된 객체의 이력 저장. 객체의 고유한 ID를 키로 사용하고, 해당 객체의 이동 경로를 값으로 저장
names = model.model.names   # YOLO 모델에서 사용된 클래스의 이름을 가져오기. 추적된 객체의 클래스 이름을 가져와서 해당 클래스의 레이블을 프레임에 표시.


# webcam 사용 시 - 실시간 개체 추적
# cap = cv2.VideoCapture(0)

# Open the video file
# video_path = "./test_self_data/IMG_4970.mp4"
video_path = "../../Server/cozy_house_backend_dev_server/resources/videos/sample_video.mp4"

cap = cv2.VideoCapture(video_path)
# assert cap.isOpened(), "Error reading video file"
# 프레임 너비와 높이, FPS 설정
w, h, fps = (int(cap.get(x)) for x in (cv2.CAP_PROP_FRAME_WIDTH, cv2.CAP_PROP_FRAME_HEIGHT, cv2.CAP_PROP_FPS))

folder_path = "./result"

# 만약 폴더가 존재하지 않으면 폴더 생성
if not os.path.exists(folder_path):
    os.makedirs(folder_path)

# VideoWriter 객체 생성
result = cv2.VideoWriter(os.path.join(folder_path, "custom_data_20sec_detec_01.mp4"),  
                         cv2.VideoWriter_fourcc(*'mp4v'),      # macOS MP4 코덱인 MP4V로 FourCC 코드 설정
                         fps,
                         (w, h))

# 비디오 프레임별 객체 추적 및 시각화
recognition_start_time = {}   # 각 객체의 인식 시작 시각

while cap.isOpened():
    # 비디오의 각 프레임마다 객체 추적을 수행
    success, frame = cap.read()
    
    # video_test라는 이름의 창에 프레임 출력
    cv2.imshow('result_video', frame)
    
    # success 변수가 True일 때 (비디오 프레임을 제대로 읽어왔을 때) 실행됨.
    if success:
        results = model.track(frame, persist=True, verbose=False, classes=0)   # 원하는 사람 클래스만 검출 : classes=사람_class_id || persist=True는 추적 결과를 계속 유지하도록 지정
        boxes = results[0].boxes.xyxy.cpu()   # results 객체에서 추적된 객체들의 경계 상자 정보를 저장

        # 추적 결과에 대한 상자 정보가 있는 경우 아래 작업을 수행
        if results[0].boxes.id is not None:

            # Extract prediction results
            clss = results[0].boxes.cls.cpu().tolist()   # 추적된 객체의 class label
            track_ids = results[0].boxes.id.int().cpu().tolist()   # 추적된 객체의 id
            confs = results[0].boxes.conf.float().cpu().tolist()   # 추적된 객체의 신뢰도 점수 (정확성)

            # Annotator Init
            annotator = Annotator(frame, line_width=2)

            for box, cls, track_id in zip(boxes, clss, track_ids):
                # 현재 시각을 해당 객체 인식 시작 시각으로 업데이트
                if track_id not in recognition_start_time:
                    recognition_start_time[track_id] = time()
                annotator.box_label(box, color=colors(int(cls), True), label=names[int(cls)])    # 프레임에 BBox 그리기. 

                # 해당 객체의 추적 이력을 저장
                track = track_history[track_id]    # track_history 딕셔너리에서 해당 객체의 추적 이력을 가져오기
                track.append((int((box[0] + box[2]) / 2), int((box[1] + box[3]) / 2)))     # 추적 이력에 현재 객체의 중심점 좌표를 추가. 중심점 좌표는 상자의 네 꼭짓점 좌표를 사용하여 계산.
                if len(track) > 30:
                    track.pop(0)     # 추적 이력의 길이가 30보다 크다면, 가장 오래된 추적 이력을 제거. (= 각 객체에 대해 최근 30프레임 동안의 이동 경로를 추적하고 기록한다)

                # 추적 이력을 사용하여 추적 경로 그리기 
                points = np.array(track, dtype=np.int32).reshape((-1, 1, 2))     # 추적 이력을 넘파이 배열로 변환
                cv2.circle(frame, (track[-1]), 7, colors(int(cls), True), -1)    # cv2.circle() 함수를 사용하여 추적 경로의 마지막 점에 원을 그리기
                cv2.polylines(frame, [points], isClosed=False, color=colors(int(cls), True), thickness=2)   # cv2.polylines() 함수를 사용하여 추적 경로를 선으로 그리기

            # 객체 인식 기간(시간) 계산 및 출력    
            for track_id in recognition_start_time:
                if track_id in track_ids:
                    recognition_duration = time() - recognition_start_time[track_id]
                    
                # 20초 이상 탐지되는 객체의 id 출력
                if recognition_duration >= 20 :
                    print(f"Object with track ID {track_id} recognized for {recognition_duration} seconds.")

        result.write(frame)
        

        if cv2.waitKey(1) & 0xFF == ord("q"):
            break
    else:
        break

# 결과 비디오 릴리스 및 종료
result.release()
cap.release()
cv2.destroyAllWindows()