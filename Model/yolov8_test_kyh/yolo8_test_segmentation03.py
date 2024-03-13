# yolo8_test_segmentation03 : 사람만 탐지하기, 20초 이상 탐지 조건

import cv2
from ultralytics import YOLO
import numpy as np
from time import time

from ultralytics.utils.checks import check_imshow   # 이미지 표시를 지원 (시각화 목적)
from ultralytics.utils.plotting import Annotator, colors    # 이미지나 비디오에서 객체를 주석 처리하고 시각화

from collections import defaultdict

# Load the YOLOv8 model
model = YOLO('yolov8n-seg.pt')

# 객체 추적과 관련된 변수 초기화
track_history = defaultdict(lambda: [])   # 추적된 객체의 이력 저장. 객체의 고유한 ID를 키로 사용하고, 해당 객체의 이동 경로를 값으로 저장
names = model.model.names   # YOLO 모델에서 사용된 클래스의 이름을 가져오기. 추적된 객체의 클래스 이름을 가져와서 해당 클래스의 레이블을 프레임에 표시.


# webcam 사용 시 - 실시간 개체 추적
# cap = cv2.VideoCapture(0)

# Open the video file
video_path = "test_video.mp4"
cap = cv2.VideoCapture(video_path)
assert cap.isOpened(), "Error reading video file"
# 프레임 너비와 높이, FPS 설정
w, h, fps = (int(cap.get(x)) for x in (cv2.CAP_PROP_FRAME_WIDTH, cv2.CAP_PROP_FRAME_HEIGHT, cv2.CAP_PROP_FPS))

# 비디오 결과 녹화 설정 : 추적된 객체가 표시된 비디오를 생성하기 위한 설정
result = cv2.VideoWriter("test_video_20sec_seg03.mp4",
                       cv2.VideoWriter_fourcc(*'mp4v'),
                       fps,
                       (w, h))

# 비디오 프레임별 객체 추적 및 시각화
recognition_start_time = {}   # 각 객체의 인식 시작 시각

while cap.isOpened():
    # 비디오의 각 프레임마다 객체 추적을 수행
    success, frame = cap.read()
    if success:
        results = model.track(frame, persist=True, verbose=False, classes=0)   # 원하는 사람 클래스만 검출 : classes=사람_class_id
        boxes = results[0].boxes.xyxy.cpu()

        if results[0].boxes.id is not None:

            # Extract prediction results
            clss = results[0].boxes.cls.cpu().tolist()   # 추적된 객체의 class label
            track_ids = results[0].boxes.id.int().cpu().tolist()   # 추적된 객체의 id
            confs = results[0].boxes.conf.float().cpu().tolist()   # 추적된 객체의 신뢰도 점수 (정확성)

            # Annotator Init
            annotator = Annotator(frame, line_width=2)

            for box, cls, track_id in zip(boxes, clss, track_ids):
                # 객체 인식 시작 시각 업데이트
                if track_id not in recognition_start_time:
                    recognition_start_time[track_id] = time()
                annotator.box_label(box, color=colors(int(cls), True), label=names[int(cls)])

                # Store tracking history
                track = track_history[track_id]
                track.append((int((box[0] + box[2]) / 2), int((box[1] + box[3]) / 2)))
                if len(track) > 30:
                    track.pop(0)

                # Plot tracks
                points = np.array(track, dtype=np.int32).reshape((-1, 1, 2))
                cv2.circle(frame, (track[-1]), 7, colors(int(cls), True), -1)
                cv2.polylines(frame, [points], isClosed=False, color=colors(int(cls), True), thickness=2)

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

