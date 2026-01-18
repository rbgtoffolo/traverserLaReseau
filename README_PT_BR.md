---

# Traverser la Réseau - Guia de Instalação

Este projeto utiliza o SuperCollider para processamento sonoro em tempo real. Para facilitar a configuração, incluímos scripts que instalam automaticamente as dependências necessárias no seu sistema.

## 📋 Pré-requisitos

* Ter o **SuperCollider** (v3.12 ou superior) instalado.
* Conexão de áudio configurada (Jack, Pipewire ou drivers ASIO no Windows).

---

## 🚀 Como Iniciar

Localize o arquivo correspondente ao seu Sistema Operacional na pasta raiz do projeto:

### 🪟 Windows (`TraverserStartWindows.bat`)

1. **Atenção ao Caminho:** O script está configurado para o padrão `C:\Program Files\SuperCollider-3.13.0\`. Se a sua versão do SuperCollider for diferente (ex: 3.12 ou 3.14), clique com o botão direito no arquivo `.bat`, escolha **Editar** e ajuste a linha `set SCLANG_PATH`.
2. **Execução:** Dê um duplo-clique no arquivo `TraverserStartWindows.bat`.
3. **Instalação:** Na primeira vez, as classes serão copiadas. Feche a janela quando solicitado e execute o arquivo novamente para abrir o programa principal.

### 🍎 macOS (`TraverserStartMac.command`)

1. **Permissão de Execução:** Antes de rodar pela primeira vez, você pode precisar dar permissão ao script. Abra o Terminal e digite:
`chmod +x /caminho/para/a/pasta/TraverserStartMac.command`
2. **Caminho do App:** O script assume que o SuperCollider está na sua pasta padrão de `/Applications`.
3. **Segurança:** Se o macOS bloquear a abertura por ser de um "Desenvolvedor Não Identificado", vá em *Ajustes do Sistema > Privacidade e Segurança* e clique em "Abrir Mesmo Assim".
4. **Instalação:** Na primeira vez, as classes serão copiadas. Feche a janela quando solicitado e execute o arquivo novamente para abrir o programa principal.

### 🐧 Linux (`TraverserStartLinux.sh`)

1. **Permissão:** Garanta que o script seja executável:
`chmod +x TraverserStartLinux.sh`
2. **Dependência de Binários:** O script utiliza o comando `sclang`. Certifique-se de que o SuperCollider está no seu `$PATH` (geralmente instalado via repositório oficial ou Flatpak).
3. **Instalação:** Na primeira vez, as classes serão copiadas. Feche a janela quando solicitado e execute o arquivo novamente para abrir o programa principal.

---

## 📂 Estrutura do Pacote

Ao extrair o projeto, certifique-se de manter a estrutura de pastas intacta:

* `installer.scd`: Responsável por verificar e copiar as classes da pasta `Dependencies` para a pasta de extensões do seu usuário.
* `traverser_live.scd`: O motor principal da aplicação.
* `Dependencies/`: Contém as classes essenciais (`HarmonicTension` e `Pousseur`). **Não mova ou renomeie esta pasta.**
* `soundfiles/`: Arquivos de áudio utilizados pelo projeto.

---

## ⚠️ Solução de Problemas (FAQ)

**1. O programa abre mas não sai som?**

* Verifique se o servidor de áudio do SuperCollider (scsynth) conseguiu inicializar. No Windows, recomenda-se o uso de drivers ASIO. No Linux, verifique a conexão com o Jack ou Pipewire.

**2. As classes não foram encontradas (Erro de "Class not defined")?**

* Isso acontece se o script não teve permissão para escrever na pasta `Extensions` do SuperCollider. Tente rodar o script de inicialização novamente ou copie manualmente as pastas dentro de `Dependencies` para a pasta de extensões do seu SuperCollider.

**3. O terminal abre e fecha muito rápido?**

* Rode o script através de um terminal aberto para ler a mensagem de erro. Geralmente é um caminho de pasta (`SCLANG_PATH`) configurado incorretamente no disparador.

---

Caso seja necessário outro tipo de ajuda, por favor entre em contato com o compositor: rael.gimenes@gmail.com
