function filter() {
  const filters = document.getElementsByName('filter');
  const image = document.getElementById('filter-image');
  const svg = document.getElementById('tracklist');
  let prevFilter = 'filter-1';

  const handleRadioChange = (evt) => {
    const newValue = evt.target.value;
    if (prevFilter !== '') {
      console.log(prevFilter)
      svg.classList.remove(prevFilter);
    }
    svg.classList.add(newValue);
    prevFilter = newValue;
    image.src = `assets/${newValue}.png`;
  }

  for (const filterRadio of filters) {
    filterRadio.addEventListener('change', handleRadioChange)
  }

  filters[0].checked = true;
}

filter();