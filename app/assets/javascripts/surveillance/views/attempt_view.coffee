class Surveillance.AttemptView extends Backbone.View
  initialize: ->
    @partialUpdateURL = @$el.data("partial-update-url")
    @$lastAnsweredSectionField = @$(".last-answered-section")
    @lastAnsweredSection = @$lastAnsweredSectionField.val()

    # Locks submissions from "Enter" key in text fields
    # If the form has a `[data-surveillance-full-form]` attribute set, it can
    # be submitted at any time
    @allowSubmission = !!@$el.data('surveillance-full-form')
    @$el.on("submit", _.bind(@ensureSubmissionAllowed, this))

    @sectionViews = _.map @$(".survey-section"), (el) =>
      section = new Surveillance.SectionView(el: el)
      @listenTo section, "validated", => @nextSection(section)
      @listenTo section, "canceled", => @previousSection(section)
      @listenTo section, "change-section", (sectionId) =>
        @changeSection(section, sectionId)
      @listenTo section, "submit-survey", => @submit()
      @listenTo section, "section-complete", => @savePartialAttemptAt(section.index)

      section

    # Fill section views with their default next and previous elements
    _.each @sectionViews, (view) =>
      view.nextSection = @nextFor(view)
      view.previousSection = @previousFor(view)

  nextSection: (view) ->
    @transition(view, view.nextSection)

  previousSection: (view) ->
    @transition(view, view.previousSection)

  changeSection: (current, nextId, mode = "next") ->
    view = @findSection(nextId)
    view.previousSection = current
    @transition(current, view)

  transition: (currentView, nextSection) ->
    currentView.$el.fadeOut 200, ->
      nextSection.$el.fadeIn(200)
      $.scrollTo(nextSection.$el, 200, offset: -60)

  nextFor: (view) ->
    _.reduce(@sectionViews, @nextIterator(view), null)

  previousFor: (view) ->
    _.reduceRight(@sectionViews, @nextIterator(view), null)

  nextIterator: (view) ->
    (found, section) ->
      return section if found == "next"
      return found if found
      return "next" if section.cid == view.cid

  findSection: (id) ->
    _.find @sectionViews, (view) -> view.id == id

  submit: ->
    @updateLanstAnsweredSection(_.last(@sectionViews).index)
    @allowSubmission = true
    @$el.submit()
    @$(".validate-survey").button("loading")

  ensureSubmissionAllowed: (e) ->
    @allowSubmission

  savePartialAttemptAt: (index) ->
    @updateLanstAnsweredSection(index)
    $.post(@partialUpdateURL, @$el.serialize())

  updateLanstAnsweredSection: (index) ->
    @$lastAnsweredSectionField.val(index) if index > @lastAnsweredSection
