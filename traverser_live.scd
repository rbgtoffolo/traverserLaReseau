/********************************
**
**       TRAVERSER LA RÉSEAU
**
**
** Rael Bertarelli Gimenes Toffolo
**
** Violocelo e electrônica em tempo real
**
** Definições de Synth
**
** Versão 2026
**/

(
s = Server.default;
s.options.memSize = 2.pow(20);
s.makeWindow;
s.mute;


~traverserPath = thisProcess.nowExecutingPath.asPathName.parentPath;

s.waitForBoot({
	var largura = 800;
    var altura = 60;
    var limitesTela = Window.screenBounds; // Pega o tamanho da sua tela atual

    ~tempWindow = Window.new("ALERTA!", Rect(
        (limitesTela.width - largura) / 2,  // Posição X (Horizontal)
        (limitesTela.height - altura) / 2, // Posição Y (Vertical)
        largura,
        altura
    ), resizable: false);

	~tempWindow.alwaysOnTop = true;

	~temptext = StaticText(~tempWindow, Rect(10,10,700, 50)).align_(\center);
	~temptext.string = "AGUARDE ... Calculando dados e carregando synths! \n Aproximadamente 20 segundos";
	~temptext.font = Font("Helvetica", 20, bold:true);

	~tempWindow.front;

	(~traverserPath ++ "variables.scd").load;
});
)
 