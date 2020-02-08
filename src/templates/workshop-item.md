<div class="workshop event"  onclick="document.location = '$tickets$'">
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
    <div class="btn-b">
      <a class="btn" href="$tickets$">Secure your spot!</a>
    </div>
  </div>
</div>
