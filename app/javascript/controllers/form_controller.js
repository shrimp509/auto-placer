import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    // Fetch all the forms we want to apply custom Bootstrap validation styles to
    const forms = document.querySelectorAll('.needs-validation')

    // Loop over them and prevent submission
    Array.from(forms).forEach(form => {
      form.addEventListener('change', event => {
        event.preventDefault(); 

        // Change style and Popup invalid msg when form invalid
        if (!form.checkValidity()) {
          event.preventDefault()
          event.stopPropagation()
        }
        form.classList.add('was-validated')
      }, false)
    })
  }
}
