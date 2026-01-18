/*

This project implement for SuperCollider the Harmonics Networks developed by Henri Pousseur as described in his paper "L'Apothéose de Rameau - Essai sur la Question Harmonique". In: Musiques Nouvelles XXI, fasc. 2-4 de la Revue d'Esthétique, Paris: Éditions Klincksieck, 1968. p.105-72

Made by Flavio Luiz Schiavoni <  >
and Rael B. Gimenes Toffolo <rael dot gimenes at gmail dot com>

Sites com documentação de SC
http://danielnouri.org/docs/SuperColliderHelp/Help.html
http://doc.sccode.org/Help.html

Para usar esta classe é necessário primeiramente instanciar uma rede de Pousseur.
A instanciação recebe como parâmetro o centro da rede e os intervalos dos eixos a serem andados.

Exemplos de eixos são: 
	- 4 semitons (terça maior)
	- 7 semintons (Quinta justa)
	- 12 semitons (oitava justa).

Uma vez montada a rede é possível pedir para traçar o caminho para encontrar determinadas notas.
Estas notas são passadas como um array de midi.

Este caminho pode ser usado em outras redes de forma que, independentemente de seus intervalos de construção,
ela irá andar por estes caminhos e encontrar as notas no meio deles.

*/

Pousseur{

var 	
	<>center, // Centro da rede. Uma nota Midi
	<>int1,  // Define a quantidade de semitons no primeiro eixo
	<>int2, // intervalo do segundo eixo
	<>int3, // intervalo do terceiro eixo
	<>path, // Guarda o caminho dos vértices até a raiz
	<>intervals; // Guarda os intervalos do caminho

/*
const <PERFECT_UNISSON	= 0;
const <MINOR_SECOND 	= 1;
const <MAJOR_SECOND 	= 2;
const <MINOR_THIRD 	= 3;
const <MAJOR_THIRD 	= 4;
const <PERFECT_FOURTH 	= 5;
const <DIMINISHED_FIFTH	= 6;
const <PERFECT_FIFTH	= 7;
const <MINOR_SIXTH 	= 8;
const <MAJOR_SIXTH 	= 9;
const <MINOR_SEVENTH 	= 10;
const <MAJOR_SEVENTH 	= 11;
const <PERFECT_OCTAVE	= 12;
*/
// O construtor irá receber 3 parametros que sao os intervalos do primeiro, segundo e terceiro eixo

*new{  arg center, int1, int2, int3;
	"INIT CLASS".postln;
	^super.new.init(center, int1, int2, int3);
	}

// Metodo de inicialização

init { arg c, x, y, z;
var queue, actualNode, nextNode;  //Guarda a fila 

this.center_(c);
this.int1_(x);
this.int2_(y);
this.int3_(z);
// Array de tamanho 128,128 para nossa matriz de adjacência
this.path = Array.newClear(128);
this.intervals = Array.newClear(128);
queue = Array.new(128);

queue.add(center);
path[center] = "R";
intervals[center] = "R";

{queue.size != 0}.while ({
	actualNode = queue[0];
	// Verifico se os filhos foram visitados e se cabem no array.

	nextNode = actualNode.asInteger + this.int1.asInteger;
	if( nextNode <= 127 and: { nextNode >= 0 and: {path[nextNode] == nil} } , {
		this.path[nextNode]=actualNode;
		this.intervals[nextNode]='F';
		queue.add(nextNode);
		});

	nextNode = actualNode.asInteger - this.int1.asInteger;
	if( nextNode <= 127 and: { nextNode >= 0 and: {path[nextNode] == nil} } , {
		this.path[nextNode]=actualNode;
		this.intervals[nextNode]='f';
		queue.add(nextNode);
		});

	nextNode = actualNode.asInteger + this.int2.asInteger;
	if( nextNode <= 127 and: { nextNode >= 0 and: {path[nextNode] == nil} } , {
		this.path[nextNode]=actualNode;
		this.intervals[nextNode]='S';
		queue.add(nextNode);
		});

	nextNode = actualNode.asInteger - this.int2.asInteger;
	if( nextNode <= 127 and: { nextNode >= 0 and: {path[nextNode] == nil} } , {
		this.path[nextNode]=actualNode;
		this.intervals[nextNode]='s';
		queue.add(nextNode);
		});

	nextNode = actualNode.asInteger + this.int3.asInteger;
	if( nextNode <= 127 and: { nextNode >= 0 and: {path[nextNode] == nil} } , {
		this.path[nextNode]=actualNode;
		this.intervals[nextNode]='T';
		queue.add(nextNode);
		});

	nextNode = actualNode.asInteger - this.int3.asInteger;
	if( nextNode <= 127 and: { nextNode >= 0 and: {path[nextNode] == nil} } , {
		this.path[nextNode]=actualNode;
		this.intervals[nextNode]='t';
		queue.add(nextNode);
		});

	queue.removeAt(0);
 });

}

// Este metodo irá receber um array de notas e transformá-lo em um array de caminhos
notes2path{ arg notes;
var output, actualNode;
output = "";

notes.size.do{|i| //Para todas as notas
	actualNode = notes[i];
	output = output ++ "C ";
	{actualNode != this.center}.while ({ //Caminha até chegar ao centro.
		output = output ++ this.intervals[actualNode] ++ " ";
		actualNode = this.path[actualNode];
	});
	output = output ++ "X ";
};
output = output[0..(output.size-2)]; // retira o último espaço em branco.
^output.split($ );
}


// Este metodo irá receber um array de caminho e devolver um array de notas
// Note que podemos ter problemas pois nao ha como garantir que o caminho cabe dentro do espaço de notas.
// Não sei o que retornar neste caso.

path2notes{ arg path;
var output, tempSum;

output = Array.new;

path.size.do{|i| //Para todas as notas
	if( path[i].ascii == "X".ascii, { output = output ++ tempSum; });	
	if( path[i].ascii == "C".ascii, { tempSum = this.center.asInteger;});	
	if( path[i].ascii == "F".ascii, { tempSum = tempSum.asInteger + this.int1.asInteger;});	
	if( path[i].ascii == "f".ascii, { tempSum = tempSum.asInteger - this.int1.asInteger;});	
	if( path[i].ascii == "S".ascii, { tempSum = tempSum.asInteger + this.int2.asInteger;});	
	if( path[i].ascii == "s".ascii, { tempSum = tempSum.asInteger - this.int2.asInteger;});	
	if( path[i].ascii == "T".ascii, { tempSum = tempSum.asInteger + this.int3.asInteger;});	
	if( path[i].ascii == "t".ascii, { tempSum = tempSum.asInteger - this.int3.asInteger;});	
};

//output = output[0..(output.size-2)]; // retira o último espaço em branco.
//^output.split($ );
^output;
}

notesNames{ arg arrayNotes;

var name, octave, testCase, nameOut, stringNotes;

stringNotes = "";
arrayNotes.do({ arg z; 
var i;
i = z.asInteger;
name = i-(12*(i.div(12)));
octave = (i.div(12))-1;

testCase = case
{name == 0 } { "C" ++ octave ++", " }
{name == 1 } { "C#" ++ octave ++", " }
{name == 2 } { "D" ++ octave ++", " }
{name == 3 } { "D#" ++ octave ++", " }
{name == 4 } { "E" ++ octave ++", " }
{name == 5 } { "F" ++ octave ++", " }
{name == 6 } { "F#" ++ octave ++", " }
{name == 7 } { "G" ++ octave ++", " }
{name == 8 } { "G#" ++ octave ++", " }
{name == 9 } { "A" ++ octave ++", " }
{name == 10 } { "A#" ++ octave ++", " }
{name == 11 } { "B" ++ octave ++", " };
stringNotes = stringNotes ++ testCase;
});
stringNotes.removeAt(stringNotes.size-1);
stringNotes.removeAt(stringNotes.size-1);
^stringNotes;
}

}
