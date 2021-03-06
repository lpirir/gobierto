this.GobiertoAdmin.ProcessesController = (function() {

  var $stageModalBackup;
  var restoreModalContentFlag = false;

  function ProcessesController() {}

  ProcessesController.prototype.form = function() {

    _addMagnificPopupBehaviors();
    _addEditStageBehaviors();
    _addCloseModalBehaviors();

    _addSetProcessDurationBehavior();
  };

  function _addMagnificPopupBehaviors() {
    // initialize one modal with several associated items
    $('[data-behavior=edit_stage]').magnificPopup({
      type:'inline',
      removalDelay: 300,
      mainClass: 'mfp-fade',
      closeMarkup: "<button title='Close (Esc)' type='button' class='mfp-close close_process_modal' data-behavior='cancel_edit_stage'>×</button>",
      closeOnBgClick: false,
      callbacks: {
        afterClose: function() {
          if (restoreModalContentFlag) {
            restoreModalContent();
          }
        },
        // Add custom behaviors to the upper right cancel edit question button (the X).
        // This button is added by Magnific Popup JS when the modal is opened, so
        // behaviors must be added in a callback.
        open: function() {
          _addCloseModalBehaviors();
        }
      }
    });
  };

  function restoreModalContent() {
    var $stageModalWrapper = $('#' + $stageModalBackup.attr('id'));

    $stageModalBackup.addClass('mfp-hide');
    $stageModalWrapper.replaceWith($stageModalBackup);

    // add handlers again
    _addMagnificPopupBehaviors();
    _addEditStageBehaviors();
    _addCloseModalBehaviors();
    _addGlobalizedFieldsBehaviors();
    addDatepickerBehaviors();

    restoreModalContentFlag = false;
  };

  function _addCloseModalBehaviors() {
    $('.close_process_modal').unbind('click', closeModal).click(closeModal);
  };

  function closeModal(e) {
    if ($(e.target).attr('data-behavior') === 'cancel_edit_stage') {
      restoreModalContentFlag = true;
    }
    $.magnificPopup.close();
  };

  function _addEditStageBehaviors() {
    var $links = $('[data-behavior=edit_stage]');
    
    $links.unbind('click', saveStageModalState).click(saveStageModalState);
  };

  function saveStageModalState(e) {    
    $stageModalBackup = $($(this).attr('href')).clone();
  };

  function _addGlobalizedFieldsBehaviors() {
    window.GobiertoAdmin.globalized_forms_component.handleGlobalizedForm();
  };

  function _addSetProcessDurationBehavior() {
    var $durationCheckbox = $('#process_has_duration');
    $durationCheckbox.click(function(){
      var $datepickersWrapper = $("[data-behavior='process_datepickers']");
      $datepickersWrapper.toggle('slow');
    });
  };

  return ProcessesController;
})();

this.GobiertoAdmin.processes_controller = new GobiertoAdmin.ProcessesController;