package main

import (
	"bufio"
	"encoding/hex"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

const banner = `
█     █████  ███  ████  █   █ ███ █   █  ███     █      ███  █   █  ███    
█░    █░░░░░█ ░░█ █░░░█ ██  █░ █░░██  █░█ ░░░    █░    █ ░░█ ██  █░█ ░░░   
█░░   ████░░█████░████░░█░█ █░░█░░█░█ █░█░ ██░   █░░   █████░█░█ █░█░ ██░  
█░░   █░░░░ █░░░█░█░░█░ █░░██░░█░░█░░██░█░░ █░   █░░   █░░░█░█░░██░█░░ █░  
█████ █████░█░░░█░█░░░█░█░░ █░███░█░░ █░░███ ░░  █████ █░░░█░█░░ █░░███ ░░ 
 ░░░░░ ░░░░░ ░░  ░░░░  ░ ░░  ░░░░░ ░░  ░░ ░░░ ░   ░░░░░ ░░  ░░░░  ░░ ░░░ ░ 
  ░░░░░ ░░░░░ ░   ░ ░   ░ ░   ░ ░░░ ░   ░  ░░░     ░░░░░ ░   ░ ░   ░  ░░░  
`

const (
	green = "\033[0;32m"
	reset = "\033[0m"
)

// Target descreve um ambiente de aprendizado (framework/linguagem).
type Target struct {
	Label     string // nome amigável exibido pro usuário
	Container string // nome do container docker
	Image     string // imagem docker usada
	Port      string // porta exposta (host:container)
	HostDir   string // caminho relativo dentro de $HOME/learning
	CreateCmd string // comando executado dentro do container para scaffolding de um projeto novo
}

var targets = map[string]Target{
	"vite": {
		Label:     "Vite",
		Container: "Vite",
		Image:     "node:24-alpine",
		Port:      "5173",
		HostDir:   filepath.Join("js-ts", "vite"),
		CreateCmd: "corepack enable pnpm && pnpm create vite",
	},
	"vue": {
		Label:     "Vue",
		Container: "Vue",
		Image:     "node:24-alpine",
		Port:      "5173",
		HostDir:   filepath.Join("js-ts", "vue"),
		CreateCmd: "corepack enable pnpm && pnpm create vue",
	},
	"next": {
		Label:     "Next",
		Container: "Next",
		Image:     "node:24-alpine",
		Port:      "3000",
		HostDir:   filepath.Join("js-ts", "next"),
		CreateCmd: "npx create-next-app@latest",
	},
	"go": {
		Label:     "Go",
		Container: "go-learning",
		Image:     "golang:alpine3.24",
		Port:      "8001",
		HostDir:   "go",
		CreateCmd: "go mod init app",
	},
	"rust": {
		Label:     "Rust",
		Container: "rust-learn",
		Image:     "rust:alpine3.24",
		Port:      "8002",
		HostDir:   "rust",
		CreateCmd: "cargo init",
	},
}

var reader = bufio.NewReader(os.Stdin)

func main() {
	printBanner()
	checkDocker()
	updateSystem()

	if len(os.Args) < 2 {
		usage()
		os.Exit(1)
	}

	key := strings.ToLower(os.Args[1])
	target, ok := targets[key]
	if !ok {
		fmt.Printf("Alvo desconhecido: %q\n\n", os.Args[1])
		usage()
		os.Exit(1)
	}

	clearAndBanner()
	runMenu(target)
}

func usage() {
	fmt.Println("Uso: learn <alvo>")
	fmt.Println("Alvos disponíveis:")
	for _, key := range []string{"vite", "vue", "next", "go", "rust"} {
		fmt.Printf("  - %s\n", key)
	}
}

func printBanner() {
	fmt.Print(green + banner + reset)
}

func clearAndBanner() {
	runInherit("clear")
	printBanner()
}

func checkDocker() {
	fmt.Println("Verificando dependências!")
	fmt.Println("Docker")
	if _, err := exec.LookPath("docker"); err != nil {
		fmt.Println("Erro: Docker não encontrado. Instale-o para continuar.")
		os.Exit(1)
	}
	fmt.Println("✅ Docker")
}

func osName() string {
	data, err := os.ReadFile("/etc/os-release")
	if err != nil {
		return ""
	}
	for _, line := range strings.Split(string(data), "\n") {
		if strings.HasPrefix(line, "NAME=") {
			return strings.Trim(strings.TrimPrefix(line, "NAME="), `"`)
		}
	}
	return ""
}

func updateSystem() {
	switch osName() {
	case "Arch Linux":
		fmt.Println("Atualizando o sistema...")
		runInherit("pacman", "-Syu", "--noconfirm")
		clearAndBanner()
	case "Ubuntu", "Debian":
		fmt.Println("Atualizando o sistema...")
		runInherit("sh", "-c", "apt update && apt upgrade -y")
		clearAndBanner()
	}
}

// runMenu mostra o menu "Novo projeto" / "Abrir existente" para o alvo escolhido.
func runMenu(t Target) {
	fmt.Printf("\nAmbiente: %s\n", t.Label)
	fmt.Println("1) Novo projeto")
	fmt.Println("2) Abrir existente")
	fmt.Print("Opção: ")

	choice := readLine()

	home, err := os.UserHomeDir()
	if err != nil {
		fmt.Println("Erro ao localizar o diretório do usuário:", err)
		os.Exit(1)
	}
	hostPath := filepath.Join(home, "learning", t.HostDir)

	if err := os.MkdirAll(hostPath, 0o755); err != nil {
		fmt.Println("Erro ao criar diretório do projeto:", err)
		os.Exit(1)
	}

	switch choice {
	case "1":
		novoProjeto(t, hostPath)
	case "2":
		abrirExistente(t, hostPath)
	default:
		fmt.Println("Opção inválida.")
		os.Exit(1)
	}
}

func novoProjeto(t Target, hostPath string) {
	clearAndBanner()
	fmt.Printf("Configurando novo projeto (%s)...\n", t.Label)

	if containerRunning(t.Container) {
		fmt.Println("Container já em operação, abrindo IDE direto.")
		abrirIDE(t)
		return
	}

	if !dirEmpty(hostPath) {
		fmt.Println("Aviso: a pasta já contém arquivos. O comando de scaffolding pode falhar ou pedir confirmação.")
	}

	subirContainer(t, hostPath)
	fmt.Println("Executando scaffolding do projeto...")
	runInherit("docker", "exec", "-it", t.Container, "sh", "-c", t.CreateCmd)

	abrirIDE(t)
}

func abrirExistente(t Target, hostPath string) {
	clearAndBanner()
	fmt.Printf("Abrindo projeto existente (%s)...\n", t.Label)

	if containerRunning(t.Container) {
		abrirIDE(t)
		return
	}

	if dirEmpty(hostPath) {
		fmt.Println("Nenhum projeto existente encontrado nessa pasta. Crie um novo primeiro (opção 1).")
		os.Exit(1)
	}

	fmt.Println("Subindo container com o projeto existente...")
	subirContainer(t, hostPath)
	abrirIDE(t)
}

func subirContainer(t Target, hostPath string) {
	runInherit("docker", "run", "-it", "-d", "--rm",
		"--name", t.Container,
		"-w", "/app",
		"-p", fmt.Sprintf("%s:%s", t.Port, t.Port),
		"-v", fmt.Sprintf("%s:/app", hostPath),
		t.Image,
	)
}

func abrirIDE(t Target) {
	fmt.Println("Abrindo IDE")
	codeAttach(t.Container, "/app")
}

// containerRunning verifica se já existe um container em execução com esse nome.
func containerRunning(name string) bool {
	out, err := exec.Command("docker", "container", "ls", "--filter", "name=^/"+name+"$", "--format", "{{.Names}}").Output()
	if err != nil {
		return false
	}
	return strings.TrimSpace(string(out)) != ""
}

// dirEmpty retorna true se o diretório não existir ou estiver vazio.
func dirEmpty(path string) bool {
	entries, err := os.ReadDir(path)
	if err != nil {
		return true
	}
	return len(entries) == 0
}

// codeAttach replica a função bash: abre o VS Code anexado ao container via vscode-remote URI.
func codeAttach(containerName, folder string) {
	hexName := hex.EncodeToString([]byte(containerName))
	uri := fmt.Sprintf("vscode-remote://attached-container+%s%s", hexName, folder)
	runInherit("code", "--folder-uri", uri)
}

func readLine() string {
	line, _ := reader.ReadString('\n')
	return strings.TrimSpace(line)
}

// runInherit executa um comando herdando stdin/stdout/stderr do processo atual.
func runInherit(name string, args ...string) {
	cmd := exec.Command(name, args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	_ = cmd.Run()
}
