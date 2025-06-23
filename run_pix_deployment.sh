#!/bin/bash

VENV_DIR="venv"
PYTHON_REQS="requirements.txt"
ANSIBLE_REQS="requirements.yml"
ENV_FILE=".env"
INVENTORY_PATH="inventory.yml"
PLAYBOOK_PATH="playbooks/pixbi_deployment_playbook.yml"

# Цветовая схема для вывода в терминале
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Прерывать выполнение скрипта при любой ошибке
set -e

# echo -e "${YELLOW}▶ Шаг 1: Установка пакета sshpass...${COLOR_NC}"
# sudo apt-get update
# sudo apt-get install sshpass -y
# echo -e "${COLOR_GREEN}✔ Пакет sshpass установлен${COLOR_NC}\n"


echo -e "${YELLOW}▶ Проверка наличия необходимых файлов...\n${NC}"
for f in "$PYTHON_REQS" "$ANSIBLE_REQS" "$ENV_FILE" "$INVENTORY_PATH" "$PLAYBOOK_PATH"; do
    if [ ! -f "$f" ]; then
        echo -e "${RED}❌ Ошибка: необходимый файл: $f\n${NC}" >&2
        exit 1
    fi
done
echo -e "${GREEN}✅ Проверка целостности файлов завершена\n\n${NC}"


echo -e "${YELLOW}▶ Создание и активация виртуального окружения Python...\n${NC}"
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    echo -e "${GREEN}✅ Виртуальное окружение создано в '$VENV_DIR'\n${NC}"
else
        echo -e "${YELLOW}ℹ️  Виртуальное окружение '$VENV_DIR' уже существует\n\n${NC}"
fi

source "${VENV_DIR}/bin/activate"
echo -e "${GREEN}✅ Виртуальное окружение активировано\n\n${NC}"


echo -e "${YELLOW}▶ Установка зависимостей Python из ${PYTHON_REQS}...\n${NC}"
pip install -r "$PYTHON_REQS"
echo -e "${GREEN}✅ Зависимости Python успешно установлены${NC}\n\n"


echo -e "${YELLOW}▶ Установка ролей и коллекций Ansible из ${ANSIBLE_REQS}...\n${NC}"
ansible-galaxy install -r "$ANSIBLE_REQS"
echo -e "${GREEN}✅ Роли и коллекции Ansible успешно установлены${NC}\n\n"


echo -e "${YELLOW}▶ Загрузка переменных окружения из ${ENV_FILE}...\n${NC}"
set -o allexport
source "$ENV_FILE"
set +o allexport
echo -e "${GREEN}✅ Переменные окружения загружены\n\n${NC}"


echo -e "${YELLOW}▶ Установка PixBI...${NC}"
ansible-playbook -i "$INVENTORY_PATH" "$PLAYBOOK_PATH"
echo -e "\n${GREEN}✅ Скрипт успешно завершил свою работу!\n
Теперь можно перейти в интернет браузере по ссылке https://${PIX_URL}\n
Стандартный логин: admin\n
Стандартный логин: Admin1Default@\n\n${NC}"
echo -e "${YELLOW}⚠️ Не забудьте сменить стандартный пароль ⚠️\n${NC}"