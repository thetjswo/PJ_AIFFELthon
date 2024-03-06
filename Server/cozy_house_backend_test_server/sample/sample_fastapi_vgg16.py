# sample_fastapi_vgg16.py
import uvicorn   # pip install uvicorn 
from fastapi import FastAPI   # pip install fastapi 
from fastapi.middleware.cors import CORSMiddleware # 추가된부분 cors 문제 해결을 위한

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
import vgg16_prediction_model



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
    return "VGG16 모델을 사용하는 API를 만들어봅시다."

@app.get('/sample')
async def sample_prediction():
    result = await vgg16_prediction_model.prediction_model()
    print("prediction was requested and done")
    return result


# Run the server
if __name__ == "__main__":
    uvicorn.run("sample_fastapi_vgg16:app",
            reload= True,   # Reload the server when code changes
            host="127.0.0.1",   # Listen on localhost 
            port=5000,   # Listen on port 5000 
            log_level="info"   # Log level
            )