from django.shortcuts import render
from django.http import HttpResponse
from django.template import loader
from django.core.files.storage import default_storage
from django.core.files.storage import FileSystemStorage
# Create your views here.

def index(request):
    template = loader.get_template('lyricsMatch/index.html')
    context = {'user_text': "This is a test"}
    return HttpResponse(template.render(context, request))


def find_lyrics(request):
    template = loader.get_template('lyricsMatch/index.html')
    context = {'list_of_songs': 'find_lyrics'}
    return HttpResponse(template.render(context, request))


def save_audio_file(request):
    audio_file = request.FILES['audio']
    print(audio_file.name)
    fs = FileSystemStorage()
    file_name = fs.save(audio_file.name, audio_file)
    template = loader.get_template('lyricsMatch/index.html')
    context = {'translated_text': "voice_to_text"}
    return HttpResponse(template.render(context, request))



def voiceToText():
    '''
    use Google speech to text API to transform the voice to text,
    return the text, shown on the web page
    :param request:
    :return:
    '''
    print("do voice to text")
    file = default_storage.open(file_name)
