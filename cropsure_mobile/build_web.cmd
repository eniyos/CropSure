@echo off
set "PATH=C:\Users\HARINA~1\OneDrive\Documents\flutter\bin;%PATH%"
set "PUB_CACHE=C:\Users\HARINA~1\AppData\Local\Pub\Cache"
cd /d "C:\Users\HARINA~1\OneDrive\Desktop\agriculture\cropsure_mobile"
call flutter build web --dart-define=CROPSURE_API_BASE_URL=http://localhost:5000
