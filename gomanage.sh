#!/bin/bash

# Цветовые коды для вывода в терминал
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # Без цвета

# Завершать скрипт при ошибках
set -e

# Пути до Docker Compose файлов
APP_COMPOSE_FILE="docker-compose.yml"
MONITOR_COMPOSE_FILE="docker-compose.monitoring.yml"

# Меню действий
function menu() {
    echo -e "${BLUE}=============================="
    echo "         GoManage"
    echo -e "==============================${NC}"
    echo -e "${GREEN}Выберите действие:${NC}"
    echo "1) Запустить приложение с ребилдом"
    echo "2) Остановить приложение"
    echo "3) Перезапустить приложение"
    echo "4) Просмотреть логи приложения"
    echo "5) Запустить мониторинг"
    echo "6) Остановить мониторинг"
    echo "7) Перезапустить мониторинг"
    echo "8) Посмотреть логи мониторинга"
    echo "9) Запустить все сервисы (приложение + мониторинг)"
    echo "10) Остановить все сервисы"
    echo "11) Статус контейнеров"
    echo "12) Выполнить миграции"
    echo "13) Тестирование и линтинг"
    echo "14) Обновить зависимости"
    echo "15) Выйти"
    read -p "Ваш выбор: " CHOICE
    case $CHOICE in
        1) start_app ;;
        2) stop_app ;;
        3) restart_app ;;
        4) view_logs_app ;;
        5) start_monitoring ;;
        6) stop_monitoring ;;
        7) restart_monitoring ;;
        8) view_logs_monitoring ;;
        9) start_all ;;
        10) stop_all ;;
        11) container_status ;;
        12) run_migrations ;;
        13) run_tests_and_lint ;;
        14) update_dependencies ;;
        15) exit 0 ;;
        *) echo -e "${RED}Неверный выбор!${NC}" ;;
    esac
}

# Функция запуска приложения с ребилдом
function start_app() {
    echo -e "${YELLOW}Запускаем приложение с ребилдом...${NC}"
    docker compose -f "$APP_COMPOSE_FILE" up --build -d --force-recreate
    echo -e "${GREEN}Приложение запущено.${NC}"
}

# Функция остановки приложения
function stop_app() {
    echo -e "${YELLOW}Останавливаем приложение...${NC}"
    docker compose -f "$APP_COMPOSE_FILE" down
    echo -e "${GREEN}Приложение остановлено.${NC}"
}

# Функция перезапуска приложения
function restart_app() {
    echo -e "${YELLOW}Перезапускаем приложение...${NC}"
    stop_app
    start_app
}

# Функция просмотра логов приложения
function view_logs_app() {
    echo -e "${YELLOW}Доступные сервисы в приложении:${NC}"
    SERVICES=$(docker compose -f "$APP_COMPOSE_FILE" ps --services)
    select SERVICE in $SERVICES; do
        if [[ -n "$SERVICE" ]]; then
            echo -e "${YELLOW}Показ логов для сервиса ${SERVICE}...${NC}"
            docker compose -f "$APP_COMPOSE_FILE" logs -f "$SERVICE"
            break
        else
            echo -e "${RED}Неверный выбор!${NC}"
        fi
    done
}

# Функция запуска мониторинга
function start_monitoring() {
    echo -e "${YELLOW}Запускаем мониторинг...${NC}"
    docker compose -f "$MONITOR_COMPOSE_FILE" up --build -d --force-recreate
    echo -e "${GREEN}Мониторинг запущен.${NC}"
}

# Функция остановки мониторинга
function stop_monitoring() {
    echo -e "${YELLOW}Останавливаем мониторинг...${NC}"
    docker compose -f "$MONITOR_COMPOSE_FILE" down
    echo -e "${GREEN}Мониторинг остановлен.${NC}"
}

# Функция перезапуска мониторинга
function restart_monitoring() {
    echo -e "${YELLOW}Перезапускаем мониторинг...${NC}"
    stop_monitoring
    start_monitoring
}

# Функция просмотра логов мониторинга
function view_logs_monitoring() {
    echo -e "${YELLOW}Доступные сервисы в мониторинге:${NC}"
    docker compose -f "$MONITOR_COMPOSE_FILE" ps
    read -p "Введите имя сервиса для просмотра логов: " SERVICE
    echo -e "${YELLOW}Показ логов для сервиса ${SERVICE}...${NC}"
    docker compose -f "$MONITOR_COMPOSE_FILE" logs -f "$SERVICE"
}

# Функция запуска всех сервисов
function start_all() {
    echo -e "${YELLOW}Запускаем все сервисы...${NC}"
    start_app
    start_monitoring
    echo -e "${GREEN}Все сервисы запущены.${NC}"
}

# Функция остановки всех сервисов
function stop_all() {
    echo -e "${YELLOW}Останавливаем все сервисы...${NC}"
    stop_app
    stop_monitoring
    echo -e "${GREEN}Все сервисы остановлены.${NC}"
}

# Функция статуса контейнеров
function container_status() {
    echo -e "${YELLOW}Состояние контейнеров приложения:${NC}"
    docker compose -f "$APP_COMPOSE_FILE" ps
    echo -e "${YELLOW}Состояние контейнеров мониторинга:${NC}"
    docker compose -f "$MONITOR_COMPOSE_FILE" ps
}

# Функция выполнения миграций
function run_migrations() {
    echo -e "${YELLOW}Выполняем миграции...${NC}"
    migrate -database "postgres://login:pass@localhost:5432/db-name?sslmode=disable" -path ./migration/postgres/apple up
    echo -e "${GREEN}Миграции выполнены.${NC}"
}

# Функция тестирования и линтинга
function run_tests_and_lint() {
    echo -e "${YELLOW}Запуск линтинга...${NC}"
    golangci-lint run
    echo -e "${GREEN}Линтинг завершён.${NC}"

    echo -e "${YELLOW}Запуск тестов...${NC}"
    go test -v -cover ./...
    echo -e "${GREEN}Тестирование завершено.${NC}"
}

# Функция обновления зависимостей
function update_dependencies() {
    echo -e "${YELLOW}Обновляем зависимости...${NC}"
    go mod tidy
    go get -u all
    go mod tidy
    echo -e "${GREEN}Зависимости обновлены.${NC}"
}

# Основной цикл
while true; do
    menu
done
