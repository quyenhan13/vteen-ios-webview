# VTeen iOS WebView

Repo này build một app iOS rất đơn giản dùng `WKWebView` để mở `https://vteen.io.vn/`.

## Cách build IPA online bằng GitHub

1. Tạo repo mới trên GitHub.
2. Upload toàn bộ file trong thư mục này lên repo.
3. Vào tab **Actions**.
4. Chạy workflow **Build IPA**.
5. Khi job xong, vào workflow run đó và tải artifact `VTeenWebView-ipa`.
6. Đổi tên hoặc giữ nguyên file `.ipa`, rồi mở bằng TrollStore để cài.

## Thay đổi nhanh

- Đổi URL: sửa `initialURL` trong `VTeenWebView/ViewController.swift`
- Đổi tên app: sửa `CFBundleDisplayName` trong `VTeenWebView/Info.plist`
- Đổi bundle ID: sửa `PRODUCT_BUNDLE_IDENTIFIER` trong `project.yml`

## Lưu ý

- Workflow này đóng gói IPA để dùng với TrollStore, không phải quy trình phát hành App Store.
- Nếu website chặn WebView hoặc chặn user-agent, app có thể không load. Trong project đã đặt sẵn một mobile Safari user-agent để tăng khả năng tương thích.
- Nếu bạn muốn icon riêng, hãy thay bộ ảnh trong `VTeenWebView/Assets.xcassets/AppIcon.appiconset`.
