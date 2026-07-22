#!/bin/bash

# BANNER ajustado (sem espaço depois do =)
BANNER="
█     █████  ███  ████  █   █ ███ █   █  ███     █      ███  █   █  ███    
█░    █░░░░░█ ░░█ █░░░█ ██  █░ █░░██  █░█ ░░░    █░    █ ░░█ ██  █░█ ░░░   
█░░   ████░░█████░████░░█░█ █░░█░░█░█ █░█░ ██░   █░░   █████░█░█ █░█░ ██░  
█░░   █░░░░ █░░░█░█░░█░ █░░██░░█░░█░░██░█░░ █░   █░░   █░░░█░█░░██░█░░ █░  
█████ █████░█░░░█░█░░░█░█░░ █░███░█░░ █░░███ ░░  █████ █░░░█░█░░ █░░███ ░░ 
 ░░░░░ ░░░░░ ░░  ░░░░  ░ ░░  ░░░░░ ░░  ░░ ░░░ ░   ░░░░░ ░░  ░░░░  ░░ ░░░ ░ 
  ░░░░░ ░░░░░ ░   ░ ░   ░ ░   ░ ░░░ ░   ░  ░░░     ░░░░░ ░   ░ ░   ░  ░░░  
"

VERDE='\033[0;32m'
RESET='\033[0m'


code-attach() {
  local hex=$(echo -n "$1" | xxd -p | tr -d '\n')
  code --folder-uri "vscode-remote://attached-container+${hex}/${2:-/}"
}

# Imprime o banner em verde
echo -e "${VERDE}${BANNER}${RESET}"


echo "Verificando dependências!"
echo "Docker"
    if ! command -v docker &> /dev/null; then
        echo "Erro: Docker não encontrado. Instale-o para continuar."
        exit 1
    else
        echo "✅ Docker"
    fi
# Identifica o Sistema Operacional
OS=$(cat /etc/os-release | grep "^NAME=" | cut -d "=" -f2 | tr -d '"')

if [ "$OS" == "Arch Linux" ]; then
    echo "Atualizando o sistema..."
    pacman -Syu --noconfirm
    clear
    echo -e "${VERDE}${BANNER}${RESET}"
elif [[ "$OS" == "Ubuntu" || "$OS" == "Debian" ]];then
    echo "Atualizando o sistema..."
    apt update && apt upgrade -y
    clear
    echo -e "${VERDE}${BANNER}${RESET}"
fi

echo ""
echo "Qual linguagem você gostaria de aprender?"
echo "1) JavaScript | TypeScript"
echo "2) Go"
echo "3) Rust"
read -p "Opção: " LANG

case "$LANG" in
    1)
        clear
        echo -e "${VERDE}${BANNER}${RESET}"
        mkdir -p $HOME/learning/js-ts
        echo ""
        echo "Qual FrameWork?"
        echo "1) Next"
        echo "2) vue"
        echo "3) Vue"
        echo "4) Blank"
        read -p "Opção: " FWK
        
        case "$FWK" in
            1)
                clear
                echo -e "${VERDE}${BANNER}${RESET}"
                echo "Configurando ambiente para JavaScript / TypeScript..."
                mkdir -p $HOME/learning/js-ts/next
                if [[ -z "$(docker container ls | grep "Next")" && -z "$(ls -A $HOME/learning/js-ts/next)" ]];then
                    docker run -it -d --rm --name Next -w /app -p 3000:3000 -v $HOME/learning/js-ts/next:/app node:24-alpine
                    docker exec -it Next sh -c "npx create-next-app@latest"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Next /app

                elif [[ -z "$(docker container ls | grep "Next")" && -n "$(ls -A $HOME/learning/js-ts/next)" ]];then
                    echo "Subindo Container"
                    docker run -it -d --rm --name Next -w /app -p 3000:3000 -v $HOME/learning/js-ts/next:/app node:24-alpine
                    echo "Volume de container já existente"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Next /app

                else
                    echo "Container e volume ja em operação"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Next /app
                fi
                ;;
            2)
                clear
                echo -e "${VERDE}${BANNER}${RESET}"
                echo "Configurando ambiente para JavaScript / TypeScript..."
                mkdir -p $HOME/learning/js-ts/vite
                if [[ -z "$(docker container ls | grep "Vite")" && -z "$(ls -A $HOME/learning/js-ts/vite)" ]];then
                    docker run -it -d --rm --name Vite -w /app -p 5173:5173 -v $HOME/learning/js-ts/vite:/app node:24-alpine
                    docker exec -it Vite sh -c "corepack enable pnpm && pnpm create vite"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Vite /app

                elif [[ -z "$(docker container ls | grep "Vite")" && -n "$(ls -A $HOME/learning/js-ts/vite)" ]];then
                    echo "Subindo Container"
                    docker run -it -d --rm --name Vite -w /app -p 5173:5173 -v $HOME/learning/js-ts/vite:/app node:24-alpine
                    echo "Volume de container já existente"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Vite /app

                else
                    echo "Container e volume ja em operação"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Vite /app
                fi
                ;;
            4)
                clear
                echo -e "${VERDE}${BANNER}${RESET}"
                echo "Configurando ambiente para JavaScript / TypeScript..."
                mkdir -p $HOME/learning/js-ts/aplications
                read -p "nome" NAME
                read -p "porta" PORT
                if [[ -z "$(docker container ls | grep "$NAME")" && -z "$(ls -A $HOME/learning/js-ts/$NAME)" ]];then
                    docker run -it -d --rm --name $NAME -w /app -p $PORT:$PORT -v $HOME/learning/js-ts/$NAME:/app node:24-alpine
                    docker exec -it Vue sh -c "corepack enable pnpm && pnpm create vue"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Vue /app

                elif [[ -z "$(docker container ls | grep "Vue")" && -n "$(ls -A $HOME/learning/js-ts/vue)" ]];then
                    echo "Subindo Container"
                    docker run -it -d --rm --name Vue -w /app -p 5173:5173 -v $HOME/learning/js-ts/vue:/app node:24-alpine
                    echo "Volume de container já existente"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Vue /app

                else
                    echo "Container e volume ja em operação"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Vue /app
                fi
                ;;
            3)
                clear
                echo -e "${VERDE}${BANNER}${RESET}"
                echo "Configurando ambiente para JavaScript / TypeScript..."
                mkdir -p $HOME/learning/js-ts/vue
                if [[ -z "$(docker container ls | grep "Vue")" && -z "$(ls -A $HOME/learning/js-ts/vue)" ]];then
                    docker run -it -d --rm --name Vue -w /app -p 5173:5173 -v $HOME/learning/js-ts/vue:/app node:24-alpine
                    docker exec -it Vue sh -c "apt install git curl"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Vue /app

                elif [[ -z "$(docker container ls | grep "Vue")" && -n "$(ls -A $HOME/learning/js-ts/vue)" ]];then
                    echo "Subindo Container"
                    docker run -it -d --rm --name Vue -w /app -p 5173:5173 -v $HOME/learning/js-ts/vue:/app node:24-alpine
                    echo "Volume de container já existente"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Vue /app

                else
                    echo "Container e volume ja em operação"
                    sleep 1
                    echo "Abrindo IDE"
                    sleep 1
                    code-attach Vue /app
                fi
                ;;
        esac
        ;;
    2)
        clear
        echo -e "${VERDE}${BANNER}${RESET}"
        echo "Configurando ambiente para Go"
        mkdir -p $HOME/learning/go
        docker run -it -d --rm --name go-learning -w /app -p 8001:8001 -v $HOME/learning/go:/app golang:alpine3.24
        sleep 2
        code-attach go-learning /app
        ;;
    3)
        clear
        echo -e "${VERDE}${BANNER}${RESET}"
        echo "Configurando ambiente para Rust"
        mkdir -p $HOME/learning/rust
        if [[ -z "$(docker container ls | grep "rust-learn")" && -z "$(ls -A $HOME/learning/rust)" ]];then
            docker run -it -d --rm --name rust-learn -w /app -p 8002:8002 -v $HOME/learning/rust:/app rust:alpine3.24
            sleep 1
            docker exec -it rust-learn sh -c "cargo init"
            sleep 1
            code-attach rust-learn /app

        elif [[ -z "$(docker container ls | grep "rust-learn")" && -n "$(ls -A $HOME/learning/rust)" ]];then
            docker run -it -d --rm --name rust-learn -w /app -p 8002:8002 -v $HOME/learning/rust:/app rust:alpine3.24
            echo "Volume existente, iniciando container."
            sleep 2
            code-attach rust-learn /app

        else
            echo "Container e Volume existente"
            sleep 1
            echo "Abrindo IDE"
            sleep 1
            code-attach rust-learn /app
        fi
        ;;
esac
