from fastapi import FastAPI

from core import config
from backend_pre_start import create_db_tables, set_log_level, welcome_func
from api.auth import router as user_router
from api.history import router as history_router
from api.policy import router as policy_router
from api.monitor import router as monitor_router


# before server start
# 로그 레벨 지정
from core.push_messaging import PushMessaging

set_log_level()
# DB 테이블 자동 생성
create_db_tables()
welcome_func()

app = FastAPI()

# after server start
# push 메세지 클래스 객체 생성
init_firebase = PushMessaging()
# fcm 연결 인증서 읽어오기
init_firebase.get_credentials()
# 가져온 인증서로 firebase sdk 초기화
init_firebase.get_default_app()


@app.get("/")
async def root():
    return {"message": config.TEST_MESSAGE}


# HTTP protocol
app.include_router(user_router, prefix="/auth")
app.include_router(history_router, prefix="/history")
app.include_router(policy_router, prefix="/policy")
app.include_router(monitor_router, prefix="/monitor")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
