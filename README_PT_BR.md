# Traverser la Réseau - Guia de Instalação

Este projeto utiliza o SuperCollider para processamento sonoro em tempo real. Para facilitar a configuração, incluímos scripts que instalam automaticamente as dependências necessárias no seu sistema.

## Pré-requisitos
- **SuperCollider** (v3.12 ou superior) deve estar instalado.
- Servidor de áudio configurado (Jack, Pipewire ou drivers ASIO no Windows).

---

## Como Iniciar

Localize o arquivo correspondente ao seu Sistema Operacional na pasta raiz do projeto:

### Windows (TraverserStartWindows.bat)
1. **Verificação de Caminho:** O script está configurado para o padrão `C:\Program Files\SuperCollider-3.13.0\`. Se a sua versão for diferente, clique com o botão direito no arquivo `.bat`, escolha **Editar** e ajuste o caminho na linha `set SCLANG_PATH`.
2. **Execução:** Dê um duplo-clique no arquivo.
3. **Instalação:** Na primeira vez, as classes serão copiadas. Se uma janela de aviso aparecer, feche-a e execute o arquivo novamente para abrir o programa principal.

### macOS (TraverserStartMac.command)
1. **Permissão de Execução:** Antes de rodar pela primeira vez, você precisa dar permissão ao script. Abra o Terminal e digite `chmod +x ` (arraste o arquivo para o terminal para completar o caminho) e aperte Enter.
2. **Caminho do App:** O script assume que o SuperCollider está na pasta padrão `/Applications`.
3. **Segurança:** Se o macOS bloquear a abertura por ser de um desenvolvedor não identificado, vá em *Ajustes do Sistema > Privacidade e Segurança* e clique em "Abrir Mesmo Assim".
4. **Instalação:** Na primeira vez, as classes serão copiadas. Se uma janela de aviso aparecer, feche-a e execute o arquivo novamente para abrir o programa principal.

### Linux (TraverserStartLinux.sh)
1. **Permissão:** Garanta que o script seja executável com o comando `chmod +x TraverserStartLinux.sh`.
2. **Execução:** Dê um duplo-clique ou execute via terminal. O script utiliza o comando `sclang`.
3. **Nautilus:** Se o script abrir como texto, verifique nas preferências do seu gerenciador de arquivos se a opção "Executar arquivos de texto executáveis" está ativa.
4. **Instalação:** Na primeira vez, as classes serão copiadas. Se uma janela de aviso aparecer, feche-a e execute o arquivo novamente para abrir o programa principal.

---

## Estrutura do Pacote
Mantenha a organização dos arquivos para que os caminhos internos funcionem:
- `installer.scd`: Script que gerencia a instalação das extensões.
- `traverser_live.scd`: O código principal da aplicação.
- `Dependencies/`: Pasta contendo as classes essenciais (HarmonicTension e Pousseur).
- `soundfiles/`: Arquivos de áudio utilizados pelo motor de síntese.

---

## Solução de Problemas (FAQ)

**1. Sem som?**
Verifique se o servidor de áudio (scsynth) inicializou corretamente. No Windows, use drivers ASIO. No Linux, verifique as conexões no QjackCtl ou similar.

**2. Erro de Classe não definida (Class not defined)?**
Isso acontece se o instalador não conseguiu copiar as pastas. Você pode copiar manualmente o conteúdo da pasta `Dependencies` para a pasta de extensões (Extensions) do seu SuperCollider.

**3. O programa fecha após a primeira execução?**
Isso é normal. O SuperCollider precisa encerrar o processo para registrar as novas classes. Basta abrir o disparador uma segunda vez.

---

Caso seja necessário outro tipo de ajuda, por favor entre em contato com o compositor: rael.gimenes@gmail.com
