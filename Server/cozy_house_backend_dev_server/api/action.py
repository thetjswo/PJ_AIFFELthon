import os
import re
from json import JSONDecodeError

from fastapi import APIRouter, Request, HTTPException, WebSocket, WebSocketDisconnect
from pydantic import BaseModel
import cv2
import base64
import asyncio
import logging

from crud.action import selected_video

router = APIRouter()


class HistoryRequest(BaseModel):
    video_id: int


class HistoryResponse(BaseModel):
    camera_name: str
    # video: str
    thumbnail: str
    created_at: str


@router.post("/saved_video", response_model=HistoryResponse)
async def saved_video_route(request: Request):
    try:
        request_data = await request.json()
        history_request = HistoryRequest(**request_data)
    except JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")

    data = selected_video(history_request.video_id)

    # 응답 데이터 생성
    response_data = HistoryResponse(
        camera_name=data['camera_name'],
        # video=data['video'],
        thumbnail=data['thumbnail'],
        created_at=data['created_at']
    )

    # JSON 형식으로 응답 반환
    return response_data


@router.websocket('/saved_video')
async def send_saved_video(websocket: WebSocket):
    await websocket.accept()

    try:
        # Open the saved video file
        # TODO: DB의 저장된 경로로 수정 - 현재는 object_detection.py 파일 실행하면 저장되는 파일 경로
        # TODO: 앱에서 요청한 정보의 영상을 가져오기 구현 : 특정 날짜 + 시간의 영상
        # video_path = './resources/videos/sample_video.mp4'

        ################################################
        file_list = os.listdir('./resources/videos')

        max = 0
        latest_file = ''
        for file in file_list:
            if file.startswith('.'):
                continue

            numbers = re.findall(r'\d+', file)
            numbers_str = ''.join(numbers)

            if int(numbers_str) > max:
                max = int(numbers_str)
                latest_file = file

        video_path = f'./resources/videos/{latest_file}'
        ################################################

        cap = cv2.VideoCapture(video_path)

        # Get video properties
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = cap.get(cv2.CAP_PROP_FPS)

        # Loop through the video frames
        while True:
            ret, frame = cap.read()
            if not ret:
                logging.info('Error: Failed to capture frame...')
                break  # End of video

            # Encode the frame as JPEG and send it through WebSocket
            encoded = cv2.imencode('.jpg', frame)[1]
            data = base64.b64encode(encoded).decode('utf-8')

            await websocket.send_text(data)

            # Control the frame rate
            await asyncio.sleep(1 / fps)

        # Release the video capture object
        cap.release()

    except WebSocketDisconnect:
        logging.info("Client Disconnected!")

    except Exception as e:
        print(f"Error occurred: {e}")
