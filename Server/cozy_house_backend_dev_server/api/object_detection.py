# 실시간 영상 송출 : uvicorn object_detection:app --host <IP주소> --port 7080 #TODO : detection port 번호 확인

import cv2
from ultralytics import YOLO
import numpy as np
from time import time
from collections import defaultdict
from ultralytics.utils.plotting import Annotator, colors
import math

import base64
import uvicorn   # pip install uvicorn 
from fastapi import FastAPI   # pip install fastapi 
from fastapi import WebSocket, WebSocketDisconnect, WebSocketException  # 웹소켓 라이브러리
import asyncio
import logging

from datetime import datetime  # 파일명에 시간을 추가하기 위한 datetime 라이브러리
import os  # 폴더 생성을 위해 추가
import re
import sys


# Create the FastAPI application
app = FastAPI()

@app.websocket('/ws/object-detection')
async def object_detection_with_tracking(websocket: WebSocket):
    await websocket.accept()
    
    # 상태 변수
    object_detection_running = False
    
    # 객체 감지 루프
    async def object_detection_loop():
        nonlocal object_detection_running  # global 변수 사용 설정
        
        # Load the YOLOv8 model - object detection
        model = YOLO('yolov8n.pt')
        track_history = defaultdict(lambda: [])
        names = model.model.names

        # 사람 탐지 여부
        human_detected = False
        human_disappeared_time = None
        
        # TODO: DAQ 연결
        # webcam 사용
        cap = cv2.VideoCapture(1)     # 사용할 camera index 사용 - 0 : 랩탑 카메라, 1 : 핸드폰 연결 카메라(슬 경우)

        # webcam 예외처리
        if not cap.isOpened():
            print("Camera open failed!")
            sys.exit()
        
        w, h = (int(cap.get(x)) for x in (cv2.CAP_PROP_FRAME_WIDTH, cv2.CAP_PROP_FRAME_HEIGHT))
        fps = 30 # 초당 프레임 30 for most webcams
        
        # TODO: DB 저장 위치 연결
        # 임시 저장위치 
        folder_path = "./result"
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)

        recognition_start_time = {}
        
        while True:
            if object_detection_running == True:          
                # 비디오의 각 프레임마다 객체 추적을 수행
                ret, frame = cap.read()
                
                # 예외처리 : 카메라 연결 안된 경우
                if not ret :
                    print("ret is not here!")
                    break
                
                # 실시간 객체 탐지
                print("====Start Object Detection====")
                results = model(frame, stream=True)
        
                # 사람 tracking
                human_tracking = model.track(frame, persist=True, verbose=False, classes=0)
                boxes = human_tracking[0].boxes.xyxy.cpu()
        
                # 사람이 감지되면
                if human_tracking[0].boxes.id is not None:
                    print("Human detected!")
        
                    # 사람이 처음 감지되었다면, 녹화 시작
                    if not human_detected:
                        human_detected = True
                        current_time = datetime.now().strftime("%d_%H%M%S")
                        file_name = f"real_time_detec_{current_time}.mp4"
                        video_saving = cv2.VideoWriter(os.path.join(folder_path, file_name),
                                                cv2.VideoWriter_fourcc(*'mp4v'),
                                                fps,
                                                (w, h))
                        human_disappeared_time = None
                        
                        # excetpion handling : VideoWriter 파일이 안 열린경우
                        if not video_saving.isOpened():
                            print('File open failed!')
                            cap.release()
                            sys.exit()

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

                    # 객체 인식 기간(시간) 계산 및 출력
                    for track_id in recognition_start_time:
                        if track_id in track_ids:
                            recognition_duration = time() - recognition_start_time[track_id]
        
                        # 20초 이상 탐지되는 객체의 id 출력
                        if recognition_duration >= 20:
                            print(f"Object with track ID {track_id} recognized for {recognition_duration} seconds.")
                            # TODO: push 메세지 요청
        
                    # 사람이 감지되면 프레임을 비디오에 쓰기
                    video_saving.write(frame)
        
                # 사람이 사라지면 사라진 시간(human_disappeared_time) 기록, human_detected 변수 False로 수정
                else:
                    if human_detected:
                        print("Human disappered!")
                        human_disappeared_time = time()
                        human_detected = False
        
                # 사람이 사라지고 10초가 지난뒤에 저장객체 해제, 사람 사라진 시간 변수(human_disappeared_time) 초기화
                if human_disappeared_time and (time() - human_disappeared_time >= 5):
                    video_saving.release()
                    human_disappeared_time = None
                
            await asyncio.sleep(0.001)  # 다른 작업에 CPU 리소스를 할당하기 위해 잠시 대기
        
        cap.release()
        
    # app에서 데이터 받는 루프
    async def websocket_recieve_loop():
        nonlocal object_detection_running  # global 변수 사용 설정
        while True:
            try:
                data = await websocket.receive_text()
                if data == 'on':
                    object_detection_running = True
                    print("==Object detection started==")
                elif data == 'off':
                    object_detection_running = False
                    print("==Object detection stopped==")
                    
            except asyncio.TimeoutError:
                pass
            except WebSocketDisconnect:  # 일정시간 이후 데이터 안오면 연결해제
                print("Client Disconnected!")
                break

    # 모든 루프 실행
    await asyncio.gather(
        websocket_recieve_loop(),
        object_detection_loop(),
    )
    
