# Stage 1: Модульное кэширование (builder)
FROM golang:1.23 AS builder

WORKDIR /app

# Копируем только файлы для зависимостей (оптимизация кэширования)
COPY go.mod go.sum ./

# Скачиваем зависимости и сохраняем в кэше
RUN go mod download

# Копируем исходный код проекта
COPY . .

# Сборка бинарного файла с отключением CGO
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /my-app ./cmd/app

# Stage 2: Финальный минималистичный образ
FROM alpine:latest

# Устанавливаем сертификаты для работы HTTPS (необходимо для большинства приложений)
RUN apk --no-cache add ca-certificates

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем собранный бинарный файл из builder
COPY --from=builder /my-app /my-app

# Устанавливаем права выполнения (на случай, если они не были установлены)
RUN chmod +x /my-app

# Определяем точку входа
ENTRYPOINT ["/my-app"]
