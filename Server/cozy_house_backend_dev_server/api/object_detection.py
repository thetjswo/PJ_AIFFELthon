# 실시간 영상 송출 : uvicorn object_detection:app --host <IP주소> --port 7090
import json

import cv2
from ultralytics import YOLO
import numpy as np
import time
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

sys.path.append('/Users/seullee/Documents/STUDY-AI/AIFFEL/Aiffelthon/R_PJ_AIFFELthon/Server/cozy_house_backend_dev_server/')

from core.push_messaging import PushMessaging
from db.dao.users_dao import get_only_user_id
from db.dao.user_devices_dao import get_push_id


# Create the FastAPI application
app = FastAPI()

# after server start
# push 메세지 클래스 객체 생성
init_firebase = PushMessaging()
# fcm 연결 인증서 읽어오기
init_firebase.get_credentials()
# 가져온 인증서로 firebase sdk 초기화
init_firebase.get_default_app()

@app.websocket('/ws/object-detection')
async def object_detection_with_tracking(websocket: WebSocket):
    await websocket.accept()
    
    # 상태 변수
    object_detection_running = False
    current_user_uid = ''
    
    # 객체 감지 루프
    async def object_detection_loop():
        nonlocal object_detection_running  # global 변수 사용 설정
        nonlocal current_user_uid
        
        # Load the YOLOv8 model - object detection
        model = YOLO('yolov8n.pt')
        track_history = defaultdict(lambda: [])
        names = model.model.names

        # 사람 탐지 여부
        human_detected = False
        human_disappeared_time = None
        
        # 프레임 세는 변수
        human_frame_count = 0
        print("human_frame_count:", human_frame_count)
        
        # 감지 기점 타임스탬프
        recognition_start_time = {}
        
        # TODO: DAQ 연결
        # webcam 사용
        cap = cv2.VideoCapture(1)     # 사용할 camera index 사용 - 0 : 랩탑 카메라, 1 : 핸드폰 연결 카메라(슬 경우)

        # webcam 예외처리
        if not cap.isOpened():
            print("Camera open failed!")
            sys.exit()
        
        w, h = (int(cap.get(x)) for x in (cv2.CAP_PROP_FRAME_WIDTH, cv2.CAP_PROP_FRAME_HEIGHT))
        # fps = 30 # 초당 프레임 30 for most webcams
        fps = cap.get(cv2.CAP_PROP_FPS) # 재생속도 테스트용
        
        # TODO: DB 저장 위치 연결
        # 임시 저장위치 
        video_folder_path = "../resources/videos"
        thumbnail_folder_path = "../resources/thumbnail"
        
        # 비디오 저장 위치 없으면 폴더 생성
        if not os.path.exists(video_folder_path):
            os.makedirs(video_folder_path)
        
        # 섬네일 저장 위치 없으면 폴더 생성
        if not os.path.exists(thumbnail_folder_path):
            os.makedirs(thumbnail_folder_path)

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
                    
                    human_frame_count += 1
                    print("human_frame_count:", human_frame_count)
                    
                    # 사람이 처음 감지되었다면, 녹화 시작
                    if not human_detected:
                        human_detected = True
                        current_time = datetime.now().strftime("%d_%H%M%S")
                        file_name = f"real_time_detec_{current_time}"
                        video_saving = cv2.VideoWriter(os.path.join(video_folder_path, f'{file_name}.mp4'),
                                                cv2.VideoWriter_fourcc(*'mp4v'),
                                                fps,
                                                (w, h))
                        human_disappeared_time = None

                        # thumbnail 저장 위치 생성
                        save_image_path = os.path.join(thumbnail_folder_path, f"{file_name}.jpg")
                        
                        # 사람 감지되자마자 첫프레임 저장
                        cv2.imwrite(save_image_path, frame)
                        print('saved first frame to thumbnail!')
                        
                        # TODO : 3초 뒤 프레임 섬네일로 저장 기능 구현
                        # if human_frame_count == 3:
                        #     print('saved 3rd frame to thumbnail!')
                        #     cv2.imwrite(save_image_path, frame)
                        
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
                            recognition_start_time[track_id] = time.time()
                        annotator.box_label(box, color=colors(int(cls), True), label=names[int(cls)])    # 프레임에 BBox 그리기.
        
                        # 해당 객체의 추적 이력을 저장
                        track = track_history[track_id]    # track_history 딕셔너리에서 해당 객체의 추적 이력을 가져오기
                        track.append((int((box[0] + box[2]) / 2), int((box[1] + box[3]) / 2)))     # 추적 이력에 현재 객체의 중심점 좌표를 추가. 중심점 좌표는 상자의 네 꼭짓점 좌표를 사용하여 계산.
                        if len(track) > 30:
                            track.pop(0)     # 추적 이력의 길이가 30보다 크다면, 가장 오래된 추적 이력을 제거. (= 각 객체에 대해 최근 30프레임 동안의 이동 경로를 추적하고 기록한다)

                    # 객체 인식 기간(시간) 계산 및 출력
                    for track_id in recognition_start_time:
                        if track_id in track_ids:
                            recognition_duration = time.time() - recognition_start_time[track_id]
        
                        # 20초 이상 탐지되는 객체의 id 출력
                        if recognition_duration >= 15:
                            print(f"Object with track ID {track_id} recognized for {recognition_duration} seconds.")
                            # TODO: push 메세지 요청
                            # uid를 통해 해당 사용자의 fcm 토큰 조회
                            user_id = get_only_user_id(current_user_uid)
                            user_push_id = get_push_id(user_id)
                            # user_push_id = 'cEpmmWVlSS6CXSBtylOWFS:APA91bGn-95vS_KDQHMQb8bjV_h60NU3TNUU-W2UbHFGSpl42_QpQM-c6mtx0if6F0NnygWhyLANxD7AAHzlisAqPcnXle5pvC7U8OVrtWqUzolK3zIrQJ8RinXE7L4e41HtXjiPxju4'
                            # fcm 토큰에 해당하는 단말기로 푸쉬 알림 전송 (일단 주의 푸쉬 전송)
                            # print(user_push_id)
                            push = PushMessaging()
                            push.caution_push(user_push_id)

                    # 사람이 감지되면 프레임을 비디오에 쓰기
                    video_saving.write(frame)
        
                # 사람이 사라지면
                else:
                    if human_detected:
                        print("Human disappered!")
                        human_disappeared_time = time.time()  # 사라진 시간(human_disappeared_time) 기록
                        human_detected = False           # human_detected 변수 False로 수정
                        human_frame_count = 0            # 프레임 카운트 초기화
        
                # 사람이 사라지고 2초가 지난뒤에  
                if human_disappeared_time and (time.time() - human_disappeared_time >= 2):
                    video_saving.release() # 영상 저장객체 해제
                    human_disappeared_time = None # 사람 사라진 시간 변수(human_disappeared_time) 초기화

            await asyncio.sleep(0.001)  # 다른 작업에 CPU 리소스를 할당하기 위해 잠시 대기
        
        cap.release()
        
    # app에서 데이터 받는 루프
    async def websocket_recieve_loop():
        nonlocal object_detection_running  # global 변수 사용 설정
        nonlocal current_user_uid
        while True:
            try:
                data = await websocket.receive_text()
                json_data = json.loads(data)

                current_user_uid = json_data['uid']

                if json_data['message'] == 'on':
                    object_detection_running = True
                    print("==Object detection started==")
                elif json_data['message'] == 'off':
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