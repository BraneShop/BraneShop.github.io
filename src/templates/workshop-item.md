<div class="workshop event"  
$if(postponed)$
  onclick="document.location = '/posts/Braneshop-Covid-19.html'"
$else$
  onclick="document.location = '$tickets$'"
$endif$
>
  <h5> $title$ - $date$ </h5>

  <ul class="normal dates">
    <li><b>Dates:</b><br />
    </li>
    $for(dates)$
      <li>$body$</li>
    $endfor$
    <li><br />
      <b>Location:</b> $location$
    </li>
  </ul>

  <div>
    $if(postponed)$
      <div class="btn-b">
        <b><a href="/posts/Braneshop-Covid-19.html">Postponed</a></b>
      </div>
    $else$
      <div class="btn-b">
        <a class="btn" href="$tickets$">Secure your spot!</a>
      </div>
    $endif$
  </div>
</div>
