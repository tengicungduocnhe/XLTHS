# BÀI TẬP LỚN HỌC PHẦN XỬ LÝ TÍN HIỆU SỐ (DSP)

## 1. Hình thức thực hiện

Làm việc theo nhóm.

## 2. Sản phẩm

- **Báo cáo:** File PDF trình bày theo đúng thể thức báo cáo khoa học.
- **Mã nguồn MATLAB:** Cấu trúc thư mục chạy sạch, có giao diện GUI/App Designer hoặc Script mô phỏng trực quan.
- **Thuyết trình & Demo:** Thuyết trình slide và thao tác trực tiếp sản phẩm phần mềm trước Giảng viên.

## 3. Chủ đề 3: Thiết kế bộ cân bằng âm thanh đa dải tần (Multi-band Audio Equalizer)

### 3.1. Đặt vấn đề

Trong kỹ thuật âm thanh, bộ Equalizer cho phép người dùng tùy chỉnh tăng/giảm biên độ tín hiệu âm nhạc ở các dải tần khác nhau.

Yêu cầu: thiết kế một bộ Equalizer 3 dải tần:

- **Bass**
- **Mid**
- **Treble**

> **Lưu ý:** Trong file đề gốc, các giá trị cụ thể trong ngoặc của Bass, Mid và Treble không hiển thị trong phần văn bản trích xuất.

### 3.2. Nhiệm vụ

#### 3.2.1. Tiền xử lý âm thanh số

- Nhập file nhạc số chất lượng cao, **16-bit**.
- Phân tích **dải động** của tín hiệu nhạc gốc.
- Phân tích **phổ tín hiệu** nhạc gốc.

#### 3.2.2. Thiết kế ngân hàng bộ lọc IIR - Filter Bank

Thiết kế ba bộ lọc:

- **Low-pass** cho dải Bass.
- **Band-pass** cho dải Mid.
- **High-pass** cho dải Treble.

Yêu cầu:

- Dựa trên họ bộ lọc tương tự **Butterworth** hoặc **Chebyshev loại I**.
- Sử dụng phương pháp **Biến đổi song tuyến tính (Bilinear Transform)** để chuyển đổi sang miền **Z**.

#### 3.2.3. Ghép nối và khảo sát ổn định

- Ghép nối song song 3 bộ lọc IIR.
- Nhân đầu ra từng bộ lọc với hệ số khuếch đại **Gain**.
- Khảo sát vị trí các **điểm cực (Poles)** của hàm truyền tổng.
- Chứng minh hệ thống luôn ổn định **BIBO** với mọi giá trị Gain trong phạm vi yêu cầu.

> **Lưu ý:** Trong file đề gốc, khoảng giá trị Gain cụ thể không hiển thị trong phần văn bản trích xuất.

#### 3.2.4. Phân tích lượng tử hóa

Đánh giá sự thay đổi đáp ứng tần số khi hệ số bộ lọc được biểu diễn dưới hai dạng:

- **Fixed-point 16-bit**
- **Floating-point**

So sánh ảnh hưởng của lượng tử hóa lên đáp ứng tần số của hệ thống.

### 3.3. Sản phẩm trên MATLAB

- Xây dựng giao diện **MATLAB App Designer** mô phỏng bàn **Mixer/Equalizer** thực tế.
- Có **3 thanh trượt** điều chỉnh các dải Bass, Mid và Treble.
- Có khả năng **phát nhạc trực tiếp theo thời gian thực**.
- Đồ thị **đáp ứng tần số tổng** phải tự động cập nhật liên tục khi người dùng kéo thanh trượt.

## 4. Thang điểm và tiêu chí đánh giá

### 4.1. Báo cáo lý thuyết và tính toán

- Cơ sở toán học chuẩn xác.
- Giải thích rõ các bước biến đổi.
- Giải thích rõ FFT.
- Giải thích rõ quá trình thiết kế bộ lọc.
- Trích dẫn nguồn tài liệu tham khảo đúng quy chuẩn.

### 4.2. Chất lượng mã nguồn MATLAB

- Code viết sạch.
- Có comment giải thích rõ ràng.
- Thuật toán tối ưu.
- Chạy đúng kết quả.
- Không bị lỗi runtime.

### 4.3. Giao diện Demo thực nghiệm

- Giao diện GUI/App Designer trực quan, dễ thao tác.
- So sánh chi tiết các đồ thị:
  - Miền thời gian trước và sau khi lọc.
  - Miền tần số trước và sau khi lọc.

### 4.4. Thuyết trình và trả lời vấn đáp

- Thuyết trình tự tin.
- Làm rõ đóng góp của từng thành viên.
- Trả lời chính xác các câu hỏi phản biện của Giảng viên.

## 5. Tóm tắt yêu cầu triển khai cho Codex

Codex cần hỗ trợ xây dựng project MATLAB theo chuỗi xử lý chính:

```text
WAV Input
    ↓
Tiền xử lý tín hiệu
    ↓
Phân tích miền thời gian + FFT
    ↓
Thiết kế IIR Filter Bank
    ├── Low-pass  → Bass
    ├── Band-pass → Mid
    └── High-pass → Treble
    ↓
Bilinear Transform → miền Z
    ↓
Điều chỉnh Gain từng dải
    ↓
Ghép song song 3 nhánh
    ↓
Phân tích poles + ổn định BIBO
    ↓
So sánh Floating-point / Fixed-point 16-bit
    ↓
MATLAB App Designer
    ↓
Phát âm thanh + cập nhật Frequency Response theo thời gian thực
```

### Mục tiêu mã nguồn

Project nên tách thành các phần rõ ràng, ví dụ:

```text
MultiBandEqualizer/
├── main.m
├── audio/
│   └── sample.wav
├── functions/
│   ├── analyzeAudio.m
│   ├── designEQFilters.m
│   ├── applyEqualizer.m
│   ├── analyzeStability.m
│   └── quantizeCoefficients.m
└── app/
    └── EqualizerApp.mlapp
```

### Yêu cầu khi Codex sinh hoặc sửa code

1. Viết MATLAB code rõ ràng, có comment.
2. Ưu tiên các hàm nhỏ, dễ kiểm thử.
3. Kiểm tra toolbox trước khi dùng hàm phụ thuộc toolbox.
4. Chạy code bằng MATLAB MCP Server sau mỗi phần quan trọng.
5. Nếu có lỗi, giải thích nguyên nhân trước khi sửa.
6. Không thay đổi yêu cầu đề bài nếu chưa được người dùng xác nhận.
