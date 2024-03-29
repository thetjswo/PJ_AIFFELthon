# 실시간 영상 송출 : uvicorn fastapi_websocket:app --host <IP주소> --port 7080


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

'''
== port number ==
8000 : saved video
7080 : cctv
'''

@app.websocket('/ws/object-detection')
async def object_detection_with_tracking(websocket: WebSocket):
    await websocket.accept()
    
    # Load the YOLOv8 model - object detection
    model = YOLO('yolov8n.pt')
    track_history = defaultdict(lambda: [])
    names = model.model.names

    # 사람 탐지 여부
    human_detected = False
    human_disappeared_time = None

    try : 
        # webcam 사용 시 - 실시간 개체 추적
        cap = cv2.VideoCapture(1)     # 사용할 camera index 사용 - 0 : 랩탑 카메라, 1 : 핸드폰 연결 카메라(슬 경우)

        # 웹캠 예외처리
        if not cap.isOpened():
            print("Camera open failed!")
            sys.exit()
        
        # w, h, fps = (int(cap.get(x)) for x in (cv2.CAP_PROP_FRAME_WIDTH, cv2.CAP_PROP_FRAME_HEIGHT, cv2.CAP_PROP_FPS))
        w, h = (int(cap.get(x)) for x in (cv2.CAP_PROP_FRAME_WIDTH, cv2.CAP_PROP_FRAME_HEIGHT))
        fps = 30 # 초당 프레임 30 for most webcams
        prev_time = 0
        
        # VideoWriter 객체 생성 - 녹화를 시작하지 않음
        folder_path = "./result"
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)

        recognition_start_time = {}

        # 카메라 / 비디오로부터 프레임 읽어오기
        while True:
            # 비디오의 각 프레임마다 객체 추적을 수행
            ret, frame = cap.read()
            
            # 경과 시간 = 현재 시간 - 이전 프레임 재생 시간 
            current_time = time() - prev_time
            
            if not ret :
                print("ret is not here!")
                break
            
            # real time video 웹소켓으로 전달
            encoded = cv2.imencode('.jpg', frame)[1]
            data = base64.b64encode(encoded).decode('utf-8')
            await websocket.send_text(data)
            
            if (ret is True) and (current_time > 1./fps) :
                
                prev_time = time()
                
                '''
                실시간 객체 탐지
                '''
                # for debugging
                # cv2.imshow('realtime_video', frame)
                print("Start Object Detecting")
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
        
                        # # 추적 이력을 사용하여 추적 경로 그리기
                        # points = np.array(track, dtype=np.int32).reshape((-1, 1, 2))     # 추적 이력을 넘파이 배열로 변환
                        # cv2.circle(frame, (track[-1]), 7, colors(int(cls), True), -1)    # cv2.circle() 함수를 사용하여 추적 경로의 마지막 점에 원을 그리기
                        # cv2.polylines(frame, [points], isClosed=False, color=colors(int(cls), True), thickness=2)   # cv2.polylines() 함수를 사용하여 추적 경로를 선으로 그리기
        
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
                if human_disappeared_time and time() - human_disappeared_time >= 10:
                    video_saving.release()
                    human_disappeared_time = None
                        
                # # 1초마다 사용자 입력을 기다림  => 주피터 노트북에서는 인식을 못함
                # if cv2.waitKey(int(1000/fps)) == 27: # 27은 esc키 번호
                #     break

            
        cap.release()
        cv2.destroyAllWindows()
    
    except WebSocketDisconnect:
        logging.info("Client Disconnected !")
        cap.release()
        cv2.destroyAllWindows()
        
    except WebSocketException:
        print(f"Someting went Wrong: {e}")
        cap.release()
        cv2.destroyAllWindows()  
