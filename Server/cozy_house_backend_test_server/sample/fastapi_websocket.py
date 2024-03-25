# uvicorn fastapi_websocket:app --host 192.168.100.159 --port 7080 
# 실행할때 : uvicorn <파일명>:app --host <YOUR IP> --port <any port:preferably 8000> 
# -> fastapi 실행하는 일반적인 명령어인듯! - 공식 깃헙에서도 이렇게 사용하라고 설명해둠

import cv2
import base64
import uvicorn   # pip install uvicorn 
from fastapi import FastAPI   # pip install fastapi 
from fastapi import WebSocket, WebSocketDisconnect, WebSocketException  # 웹소켓 라이브러리
import asyncio
import logging


# Create the FastAPI application
app = FastAPI()

'''
== port number ==
8000 : saved video
7080 : cctv
'''
port = 7080

logging.info("Started server on port : ", port)

# 웹소켓 설정 (ws://192.168.100.159:7080/ws 로 접속)
@app.websocket('/ws')
async def cctv_streaming(websocket: WebSocket):
    logging.info("Client Connected !")
    await websocket.accept()  # client의 websocket 연결 허용

    try :
        # video_path = './test_video_20sec_detec_15_114319.mp4'
        # cap = cv2.VideoCapture(video_path)   # use saved video
        cap = cv2.VideoCapture(1) # connect to smartphone camera:1 / laptop camera:0

        # 프레임 가로 크기 지정
        cap.set(3, 960)
        # 프레임 세로 크기 지정
        cap.set(4, 640)

        while True:
            ret, frame = cap.read()
            if not ret:
                logging.info('Error: Failed to capture frame...')
                break
            
            # for debugging
            cv2.imshow('video', frame)

            encoded = cv2.imencode('.jpg', frame)[1]

            # data = str(base64.b64encode(encoded))
            # data = data[2:len(data) - 1]  # 'b...' 필요없는 문자 슬라이싱

            # await websocket.send(data)
            data = base64.b64encode(encoded).decode('utf-8')
            await websocket.send_text(data)
            
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

if __name__ == "__main__":
    uvicorn.run("fastapi_websocket:app",
            reload= True,   # Reload the server when code changes
            host="192.168.100.159", # Listen on current IP address - mac
            port=port,   # Listen on port
            )
