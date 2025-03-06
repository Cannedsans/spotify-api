async function play() {
    await fetch('/play', { method: 'POST' });
}

async function pause() {
    await fetch('/pause', { method: 'POST' });
}

async function next() {
    await fetch('/next', { method: 'POST' });
}

async function previous() {
    await fetch('/previous', { method: 'POST' });
}

// Função para extrair a cor predominante da imagem
function getDominantColor(image) {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    canvas.width = image.width;
    canvas.height = image.height;
    ctx.drawImage(image, 0, 0, image.width, image.height);

    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const data = imageData.data;
    let r = 0, g = 0, b = 0;

    for (let i = 0; i < data.length; i += 4) {
        r += data[i];
        g += data[i + 1];
        b += data[i + 2];
    }

    r = Math.floor(r / (data.length / 4));
    g = Math.floor(g / (data.length / 4));
    b = Math.floor(b / (data.length / 4));

    return `rgb(${r}, ${g}, ${b})`;
}

// Atualiza a cor do reprodutor com base na cor predominante
function updatePlayerColor() {
    const albumCover = document.getElementById('album-cover');
    const player = document.querySelector('.player');
    const dominantColor = getDominantColor(albumCover);
    player.style.backgroundColor = dominantColor;
}

// Carrega a imagem e atualiza a cor
const albumCover = document.getElementById('album-cover');
albumCover.onload = updatePlayerColor;