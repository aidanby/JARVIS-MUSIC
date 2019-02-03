import requests

def filter_out_words(sentence):
    base_url = 'https://ZyFly.lib.id/lyricsMatch@dev/'
    params = {'sentence': sentence}
    response = requests.get(base_url, params)
    data = response.json()
    return data


print(filter_out_words('what the fuck boy'))
