from django.shortcuts import render
from .models import contribution
from .forms import FormulariContribution
from django.utils import timezone
from django.shortcuts import redirect



posts = [
    {
        'author': 'John Doe',
        'title': 'Trying',
        'url': 'google',
        'content': 'Trying...',
        'date_posted': '24/10/2020',
    }
]

def home(request):
    #Si comentamos la linea de abajo sale el predeterminado de arriba
    posts = contribution.objects.order_by(contribution.points)
    return render(request, 'aswprojecte_app/home.html', {'posts': posts})

def submit(request):
    if request.method == "POST":
        form = FormulariContribution(request.POST)
        if form.is_valid():
            contribution = form.save(commit=False)
            contribution.points = 3
            contribution.date = timezone.now()
            contribution.save()
            return redirect(new)
    else:
        form = FormulariContribution()
        return render(request, 'aswprojecte_app/submit.html', {'form': form})

def new(request):
    posts = contribution.objects.order_by('date')
    return render(request, 'aswprojecte_app/new.html', {'posts':posts})
