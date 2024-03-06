# sample_fastapi_vgg16.py
import uvicorn   # pip install uvicorn 
from fastapi import FastAPI   # pip install fastapi 
from fastapi.middleware.cors import CORSMiddleware # 추가된부분 cors 문제 해결을 위한
from fastapi import WebSocket  # 웹소켓 라이브러리

# 상대경로 참조 - 현재 파일이 위치한 디렉토리의 상위 디렉토리를 시스템 경로에 추가
import sys
import os

# 현재 작업중인 디렉토리 경로
current_dir = os.path.dirname(os.path.abspath(__file__))
print(current_dir)

# 모듈이 위치한 디렉토리 경로 계산
module_dir = os.path.join(current_dir, '..', '..', 'Model', 'sample_img_classification')
print(module_dir)

# 계산된 모듈 디렉토리를 시스템 경로에 추가
sys.path.append(module_dir)

# 예측 모듈 가져오기
from tests import vgg16_prediction_model



# Create the FastAPI application
app = FastAPI()

# cors 이슈
origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# A simple example of a GET request
@app.get("/")
async def read_root():
    print("url was requested")
    return "VGG16 모델을 사용하는 API를 만들어봅시다!!!"

# @app.get('/sample')
# async def sample_prediction():
#     result = await vgg16_prediction_model.prediction_model()
#     print("prediction was requested and done")
#     return result

# 웹소켓 설정 (ws://127.0.0.1:5000/ws 로 접속)?
@app.websocket('/ws')
async def websocket_endpoint(websocket: WebSocket):
    print(f"Client connected: {websocket.client}")
    await websocket.accept()  # client의 websocket 연결 허용
    await websocket.send_text(f"Welcome client: {websocket.client}")
    while True:
        # 예측 모델 사용해서 데이터를 처리하고 결과 생성
        result = await vgg16_prediction_model.prediction_model() # 예측모델 호출
        print(f"Sending result to client: {result}")
        await websocket.send_text(result) # 클라이언트에게 결과 전송
        

# python sample_fastapi_websocket_vgg16.py 로 실행할경우 수행되는 구문
if __name__ == "__main__":
    uvicorn.run("sample_fastapi_vgg16:app",
            reload= True,   # Reload the server when code changes
            host="127.0.0.1",   # Listen on localhost 
            port=5000,   # Listen on port 5000 
            log_level="info"   # Log level
            )