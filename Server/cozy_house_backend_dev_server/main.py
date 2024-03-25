from fastapi import FastAPI, Request
from core import config
from backend_pre_start import create_db_tables, set_log_level, welcome_func
from api.auth import router as user_router


app = FastAPI()

# 로그 레벨 지정
set_log_level()
# DB 테이블 자동 생성
create_db_tables()
welcome_func()

@app.get("/")
async def root():
    return {"message": config.TEST_MESSAGE}


app.include_router(user_router, prefix="/auth")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
