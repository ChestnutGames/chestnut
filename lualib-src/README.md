### 设计c服务
- 假如你需要写一个c服务提高性能，最好用lua作为协议分发，用c实现实现逻辑提高性能，并且分一个文件夹与之命名。
- 最好不要全部用c实现
- 如果有用纯c实现的服务，客户端放在client里面，消息定义放在foundation/msg
### 第三方完整库请放在外面
### 自己修改的第三方库放在chestnut里面