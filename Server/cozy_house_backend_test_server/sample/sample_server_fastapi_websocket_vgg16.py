
import uvicorn   # pip install uvicorn 
from fastapi import FastAPI   # pip install fastapi 
from fastapi import WebSocket  # 웹소켓 라이브러리
import asyncio

# 상대경로 참조 - 현재 파일이 위치한 디렉토리의 상위 디렉토리를 시스템 경로에 추가
import sys
import os

# 현재 작업중인 디렉토리 경로
current_dir = os.path.dirname(os.path.abspath(__file__))
print(current_dir)

# 모듈이 위치한 디렉토리 경로 계산
module_dir = os.path.join(current_dir, '..', 'Model', 'sample_img_classification')
print(module_dir)

# 계산된 모듈 디렉토리를 시스템 경로에 추가
sys.path.append(module_dir)

# 예측 모듈 가져오기
import vgg16_prediction_model


# Create the FastAPI application
app = FastAPI()

# 웹소켓 설정 (ws://192.168.100.159:5000/ws 로 접속)
@app.websocket('/ws')
async def data(websocket: WebSocket):
    print(f"Client connected: {websocket.client}")
    await websocket.accept()  # client의 websocket 연결 허용
    await websocket.send_text(f"Welcome client: {websocket.client}")

    # 디버깅용 메세지 전송
    await websocket.send_text("Debugging message from server")
    while True:
        # 예측 모델 사용해서 데이터를 처리하고 결과 생성
        result = await vgg16_prediction_model.prediction_model() # 예측모델 호출
        print("prediction was requested and done")
        print(f"Sending result to client: {result}")
        # await websocket.send_text(result) # 클라이언트에게 결과 전송
        await websocket.send_json(result)
        await asyncio.sleep(1)


# python sample_server_fastapi_websocket_vgg16.py 로 실행할경우 수행되는 구문
if __name__ == "__main__":
    uvicorn.run("sample_server_fastapi_websocket_vgg16:app",
            reload= True,   # Reload the server when code changes
            # host="127.0.0.1",   # Listen on localhost of ios
            # host="10.0.2.2",   # Listen on localhost of android -> 이건 mac에서 실행 안됨
            host="192.168.100.159", # Listen on current IP address - 192.168.100.159 / 0.0.0.0 은 안됨
            port=5000,   # Listen on port 5000 
            )

# 실행할때 : uvicorn main:app --host <YOUR IP> --port <any port:preferably 8000> 
# -> fastapi 실행하는 일반적인 명령어인듯! - 공식 깃헙에서도 이렇게 사용하라고 설명해둠 