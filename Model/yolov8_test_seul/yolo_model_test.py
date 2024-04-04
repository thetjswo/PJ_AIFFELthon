# yolo_v8_detection_for_server : yolo_v8_detection 을 함수화

import cv2
from ultralytics import YOLO
import numpy as np
from time import time
from collections import defaultdict
from ultralytics.utils.plotting import Annotator, colors
import math 

from datetime import datetime  # 파일명에 시간을 추가하기 위한 datetime 라이브러리
import os  # 폴더 생성을 위해 추가
import re

import logging # log 출력을 위한 라이브러리


def object_detection_with_tracking():
    # Load the YOLOv8 model - object detection
    model = YOLO('yolov8n.pt')
    track_history = defaultdict(lambda: [])
    names = model.model.names

    # # webcam 사용 시 - 실시간 개체 추적
    cap = cv2.VideoCapture(1)     # 사용할 camera index 사용 - 0 : 랩탑 카메라, 1 : 핸드폰 연결 카메라(슬 경우)
    
    # using sample video file
    # cap = cv2.VideoCapture(video_path)
    # assert cap.isOpened(), "Error reading video file"
    
    w, h, fps = (int(cap.get(x)) for x in (cv2.CAP_PROP_FRAME_WIDTH, cv2.CAP_PROP_FRAME_HEIGHT, cv2.CAP_PROP_FPS))

    # 현재 시간을 포맷에 맞게 문자열로 변환하여 파일명에 추가
    current_time = datetime.now().strftime("%d_%H%M%S")
    # 파일명에 현재 시간 추가
    file_name = f"real_time_detec_{current_time}.mp4"

    folder_path = "./result"

    # 만약 폴더가 존재하지 않으면 폴더 생성
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    
    # VideoWriter 객체 생성
    result = cv2.VideoWriter(os.path.join(folder_path, file_name),  
                             cv2.VideoWriter_fourcc(*'mp4v'),      # macOS MP4 코덱인 MP4V로 FourCC 코드 설정
                             fps,
                             (w, h))

    recognition_start_time = {}

    # 사람 탐지 여부
    human_detected = False
    
    # 카메라 / 비디오로부터 프레임 읽어오기
    while cap.isOpened():
        # 비디오의 각 프레임마다 객체 추적을 수행
        success, frame = cap.read()
        
        # for debugging
        cv2.imshow('realtime_video', frame)
        
        # success 변수가 True일 때 (비디오 프레임을 제대로 읽어왔을 때)
        while success:
            '''
            실시간 객체 탐지
            '''
            print("Start Object Detecting")
            results = model(frame, stream=True)
            
            # 사람 tracking
            human_tracking = model.track(frame, persist=True, verbose=False, classes=0)
            boxes = human_tracking[0].boxes.xyxy.cpu()
            
            # 사람이 감지되면
            while human_tracking[0].boxes.id is not None:
                print("Human detected!")
                human_detected = True
                # Extract prediction results
                clss = human_tracking[0].boxes.cls.cpu().tolist()   # 추적된 객체의 class label
                track_ids = human_tracking[0].boxes.id.int().cpu().tolist()   # 추적된 객체의 id
                confs = human_tracking[0].boxes.conf.float().cpu().tolist()   # 추적된 객체의 신뢰도 점수 (정확성)

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
                        #TODO: push 메세지 요청
                        
            result.write(frame)
            
            # # coordinates
            # for r in results:
            #     boxes = r.boxes

            #     for box in boxes:
            #         # bounding box
            #         x1, y1, x2, y2 = box.xyxy[0]
            #         x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2) # convert to int values

            #         # put box in cam
            #         cv2.rectangle(frame, (x1, y1), (x2, y2), (255, 0, 255), 3)

            #         # confidence
            #         confidence = math.ceil((box.conf[0]*100))/100
            #         # print("Confidence --->",confidence)

            #         # class name
            #         cls = int(box.cls[0])
            #         # print("Class name -->", names[cls])

            #         # object details
            #         org = [x1, y1]
            #         font = cv2.FONT_HERSHEY_SIMPLEX
            #         fontScale = 1
            #         color = (255, 0, 0)
            #         thickness = 2

            #         cv2.putText(frame, names[cls], org, font, fontScale, color, thickness)
                    
            # 사람 사라지면 녹화 중단
            if human_tracking[0].boxes.id is None:
                print("Human disappered!")
                break
        # else:
        #     break

    result.release()
    cap.release()
    cv2.destroyAllWindows()
    
    return result


# # 이 파일을 직접 실행할때
# video_path = "./sample_data/sample_video.mp4"

# # # server에서 모델 호출할때 : server 파일 실행 위치에서 상대경로
# # video_path = "../../../Model/sample_data/sample_video.mp4"

result_video_path = object_detection_with_tracking()
print(f"Result video saved at: {result_video_path}")
