(
// 1. Configurações de caminhos
var sourcePath = thisProcess.nowExecutingPath.asPathName.parentPath ++ "Dependencies";
var targetRoot = Platform.userExtensionDir;
var mainCodePath = thisProcess.nowExecutingPath.asPathName.parentPath ++ "traverser_live.scd";

fork {
    var precisaReiniciar = false;

    // Função interna para cópia recursiva
    var updateFolder = { |src, dest|
        if (File.exists(dest).not) { File.mkdir(dest) };
        PathName(src).entries.do({ |entry|
            // Para arquivos dentro da pasta, usamos fileName
            // Para subpastas, folderName
            var name = if(entry.isFolder) { entry.folderName } { entry.fileName };
            var newSrc = src +/+ name;
            var newDest = dest +/+ name;

            if (name.notEmpty && (name.at(0) != $.)) {
                if (entry.isFolder) {
                    updateFolder.value(newSrc, newDest);
                } {
                    if(File.exists(newDest)) { File.delete(newDest) };
                    File.copy(newSrc, newDest);
                };
            };
        });
    };

    "--- VERIFICANDO INSTALAÇÃO ---".postln;

    if (File.exists(sourcePath)) {
        PathName(sourcePath).entries.do({ |entry|
            // CORREÇÃO CRÍTICA: Se for pasta, pega folderName. Se for arquivo, fileName.
            var itemName = if(entry.isFolder) { entry.folderName } { entry.fileName };
            var finalDest = targetRoot +/+ itemName;

            if (itemName.notEmpty && (itemName.at(0) != $.)) {

                "Verificando item: %".format(itemName).postln;

                if (File.exists(finalDest).not) {
                    "A instalar nova extensão: %".format(itemName).postln;
                    if (entry.isFolder) {
                        updateFolder.value(entry.fullPath, finalDest);
                    } {
                        File.copy(entry.fullPath, finalDest);
                    };
                    precisaReiniciar = true;
                } {
                    "Extensão % já presente.".format(itemName).postln;
                };
            };
        });

        if (precisaReiniciar) {
            {
                var win = Window("Instalação", Rect(400, 400, 300, 150)).front;
                win.alwaysOnTop = true;
                win.view.layout_(VLayout(
                    StaticText().string_("Classes instaladas com sucesso!").align_(\center),
                    StaticText().string_("O SuperCollider vai reiniciar.").align_(\center),
                    StaticText().string_("RODE O SCRIPT NOVAMENTE APÓS O REINÍCIO").font_(Font(bold:true)).align_(\center),
                    Button().states_([["Entendido"]]).action_({ win.close; 0.exit })
                ));

            }.defer;

            5.wait;
            //thisProcess.recompile;

        } {
            "--- TUDO PRONTO ---".postln;
            "A carregar o código principal...".postln;
            0.5.wait;
            {
                if(File.exists(mainCodePath)) {
                    mainCodePath.load;

                } {
                    "ERRO CRÍTICO: O ficheiro % não foi encontrado!".format(mainCodePath).warn;
                };
            }.defer;
        };

    } {
        "ERRO: Pasta 'Dependencies' não encontrada no projeto!".warn;
    };
}
)