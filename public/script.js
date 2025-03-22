const img = document.getElementById("album-cover")

async function play() {
    await fetch('/play', { method: 'POST' });
}

async function pause() {
    await fetch('/pause', { method: 'POST' });
}

async function next() {
    await fetch('/next', { method: 'POST' });
    carregarImagem() 
}

async function previous() {
    await fetch('/previous', { method: 'POST' });
    carregarImagem() 
}

async function carregarImagem() {
    try {
        const resposta = await fetch('/capa', { method: 'GET' });

        if (!resposta.ok) {
            throw new Error(`Erro ao carregar imagem: ${resposta.statusText}`);
        }

        const blob = await resposta.blob();
        const img = document.getElementById('album-cover');

        if (img) {
            img.src = URL.createObjectURL(blob);
        } else {
            console.error('Elemento <img> não encontrado.');
        }
    } catch (erro) {
        console.error('Erro ao buscar a imagem:', erro);
    }
}
