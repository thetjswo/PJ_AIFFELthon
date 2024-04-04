# 저장된 영상 송출 : uvicorn saved_video:app --host <IP주소> --port 7070

import cv2
import base64
import uvicorn   # pip install uvicorn 
from fastapi import FastAPI   # pip install fastapi 
from fastapi import WebSocket, WebSocketDisconnect, WebSocketException  # 웹소켓 라이브러리
import asyncio
import logging

# Create the FastAPI application
app = FastAPI()

@app.websocket('/ws/saved-video')
async def send_saved_video(websocket: WebSocket):
    await websocket.accept()
    try:
        # Open the saved video file
        # TODO: DB의 저장된 경로로 수정 - 현재는 object_detection.py 파일 실행하면 저장되는 파일 경로
        # TODO: 앱에서 요청한 정보의 영상을 가져오기 구현 : 특정 날짜 + 시간의 영상
        video_path = '../resources/videos/sample_video.mp4'
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