Selfstarter.campaigns =

  init: ->

    _this = this

    $("#video_image").on "click", ->
      $("#player").removeClass("hidden")
      $("#player").css('display', 'block')
      $(this).hide()

    # Checkout section functions:
    $('#quantity').on "change", (e) ->
      quantity = $(this).val()
      $amount = $('#amount')
      new_amount = parseFloat($amount.attr('data-original')) * quantity
      $amount.val(new_amount)
      $('#total').html(new_amount.toFixed(2))

    $('#amount').focus()

    $('.reward_option.active').on "click", (e) ->
      $this = $(this)
      $amount = $('#amount')
      $this.find('input').prop('checked', true)
      $('.reward_option').css('background-color', '')
      $this.css('background-color', '#e6e6e6')
      $amount.val($this.attr('data-price'))

  submitPaymentForm: (form) ->
    $('#errors').hide()
    $('#errors').html('')
    $('button[type="submit"]').attr('disabled', true).html('Processing, please wait...')
    $('#card_number').removeAttr('name');
    $('#security_code').removeAttr('name');

    $form = $(form)

    cardData =
      number: $form.find('#card_number').val()
      expiration_month: $form.find('#expiration_month').val()
      expiration_year: $form.find('#expiration_year').val()
      security_code: $form.find('#security_code').val()

    errors = crowdtilt.card.validate(cardData)
    if !$.isEmptyObject(errors)
      $.each errors, (index, value) ->
        $('#errors').append('<p>' + value + '</p>')
      $('#errors').show()
      $('.loader').hide()
      $button = $('button[type="submit"]')
      $button.attr('disabled', false).html('Confirm payment of $' + $button.attr('data-total'))
      $('#card_number').attr('name', 'card_number');
      $('#security_code').attr('name', 'security_code');
    else
      user_id = $form.find('#ct_user_id').val()
      crowdtilt.card.create(user_id, cardData, this.cardResponseHandler)


  cardResponseHandler: (response) ->
    switch response.status
      when 201
        token = response.card.id
        input = $('<input name="ct_card_id" value="' + token + '" type="hidden" />');
        form = document.getElementById('payment_form')
        form.appendChild(input[0])
        form.submit()
      else
        $('#errors').append('<p>An error occurred. Please check your credit card details and try again.</p>')
        $('#errors').show()
        $('.loader').hide()
        $button = $('button[type="submit"]')
        $button.attr('disabled', false).html('Confirm payment of $' + $button.attr('data-total') )
        $('#card_number').attr('name', 'card_number');
        $('#security_code').attr('name', 'security_code');
