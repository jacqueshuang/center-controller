import uvicorn
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from typing import List

app = FastAPI()

# 用于存储所有活动的 WebSocket 连接
active_connections: List[WebSocket] = []

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str):
    # 检查是否已经有连接存在
    await websocket.accept()
    active_connections.append(websocket)
    print(f"新的客户端连接: {websocket.client.host}:{websocket.client.port}")
    print(f"设备id: {client_id}")
    await websocket.send_text("你的设备id是: "+client_id)
    try:
        while True:
            # 等待接收客户端消息
            data = await websocket.receive_text()
            print(f"从 {websocket.client.host}:{websocket.client.port} 收到消息: {data}")
            # 将收到的消息原样发回给客户端 (Echo)
            await websocket.send_text(f"服务器收到并回显: {data}")
            # 如果您想广播给所有连接的客户端，可以这样做：
            # for connection in active_connections:
            #     if connection != websocket: # 不发给自己
            #         await connection.send_text(f"用户 {websocket.client.host}:{websocket.client.port} 说: {data}")
            #     else:
            #         await connection.send_text(f"您的消息已发送: {data}")


    except WebSocketDisconnect:
        active_connections.remove(websocket)
        print(f"客户端断开连接: {websocket.client.host}:{websocket.client.port}")
    except Exception as e:
        active_connections.remove(websocket)
        print(f"发生错误导致客户端 {websocket.client.host}:{websocket.client.port} 断开: {e}")
        # 确保在异常时也尝试关闭连接
        try:
            await websocket.close()
        except RuntimeError: # 可能已经关闭
            pass

@app.get("/")
async def get_root():
    return "中控器服务器运行中..."

if __name__ == "__main__":

    uvicorn.run("main:app", host="0.0.0.0", port=15400, reload=True)
    # 如果不想用 reload，可以这样：
    # uvicorn.run(app, host="0.0.0.0", port=8000)