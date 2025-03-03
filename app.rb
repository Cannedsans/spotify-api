require 'sinatra'
require 'httparty'
require 'dotenv'

Dotenv.load
enable :sessions

# Carrega variáveis de ambiente
id = ENV['SPOTIFY_CLIENT_ID']
secret = ENV['SPOTIFY_CLIENT_SECRET']
uri = ENV['SPOTIFY_REDIRECT_URI']

# Endpoints do Spotify
SPOTIFY_AUTH_URL = 'https://accounts.spotify.com/authorize'
SPOTIFY_TOKEN_URL = 'https://accounts.spotify.com/api/token'

# Escopos necessários
SCOPES = 'user-read-playback-state user-modify-playback-state'

# Configura o servidor para rodar na porta 3000
set :port, 3000
set :session_secret, ENV['SESSION_SECRET'] || 'super_secreto' # Use uma chave secreta segura

get '/' do
  # Redireciona o usuário para a página de autorização do Spotify
  redirect "#{SPOTIFY_AUTH_URL}?client_id=#{id}&response_type=code&redirect_uri=#{uri}&scope=#{SCOPES}"
end

get '/callback' do
  code = params[:code]

  response = HTTParty.post(SPOTIFY_TOKEN_URL, body: {
    grant_type: 'authorization_code',
    code: code,
    redirect_uri: uri,
    client_id: id,
    client_secret: secret
  })

  puts "Resposta da API do Spotify: #{response.body}" # <-- Adiciona log

  if response.success?
    session[:access_token] = response['access_token']
    session[:refresh_token] = response['refresh_token']

    redirect '/control'
  else
    "Erro ao obter token: #{response.body}"
  end
end


# Página de controle
get '/control' do
  # Depuração: Verifica se o token de acesso está definido
  puts "Access Token: #{session[:access_token]}"

  if session[:access_token]
    # Exibe botões para controlar a música
    <<-HTML
      <h1>Controle do Spotify</h1>
      <button onclick="previous()">Anterior</button>
      <button onclick="play()">Play</button>
      <button onclick="pause()">Pause</button>
      <button onclick="next()">Próxima</button>

      <script>
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
          await fetch('/previous', { method: 'POST'});
        }
      </script>
    HTML
  else
    "Erro: Token de acesso não encontrado. Tente acessar novamente."
  end
end


# Endpoint para tocar música
post '/play' do
  access_token = session[:access_token]
  response = HTTParty.put('https://api.spotify.com/v1/me/player/play', headers: {
    'Authorization' => "Bearer #{access_token}"
  })

  if response.success?
    'Tocando música...'
  else
    "Erro ao tocar música: #{response.body}"
  end
end

# Endpoint para pausar música
post '/pause' do
  access_token = session[:access_token]
  response = HTTParty.put('https://api.spotify.com/v1/me/player/pause', headers: {
    'Authorization' => "Bearer #{access_token}"
  })

  if response.success?
    'Música pausada.'
  else
    "Erro ao pausar música: #{response.body}"
  end
end

# Endpoint para pular para a próxima música
post '/next' do
  access_token = session[:access_token]
  response = HTTParty.post('https://api.spotify.com/v1/me/player/next', headers: {
    'Authorization' => "Bearer #{access_token}"
  })

  if response.success?
    'Próxima música.'
  else
    "Erro ao pular música: #{response.body}"
  end
end

post '/previous' do
  access_token = session[:access_token]
  response = HTTParty.post('https://api.spotify.com/v1/me/player/previous', headers: {
    'Authorization' => "Bearer #{access_token}"
  })

  if response.success?
    'Voltar música.'
  else
    "Erro ao voltar música: #{response.body}"
  end
end
