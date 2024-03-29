# 실시간 영상 송출 : uvicorn real_time_streaming:app --host <IP주소> --port 7080

import cv2
import base64
import uvicorn   # pip install uvicorn 
from fastapi import FastAPI   # pip install fastapi 
from fastapi import WebSocket, WebSocketDisconnect, WebSocketException  # 웹소켓 라이브러리
import asyncio
import logging

# Create the FastAPI application
app = FastAPI()

@app.websocket('/ws/real-time-streaming')
async def real_time_streaming(websocket: WebSocket):
    await websocket.accept()
    try:
        # webcam 사용 시 - 실시간 개체 추적
        cap = cv2.VideoCapture(0)     # 사용할 camera index 사용 - 0 : 랩탑 카메라, 1 : 핸드폰 연결 카메라(슬 경우)

        # Get video properties
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = 30

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