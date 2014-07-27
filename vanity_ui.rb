require 'fox16'
include Fox

NUMBERS = (1..9).to_a
ALPHABET_LOWER = ("a".."z").to_a
ALPHABET_UPPER = ("A".."Z").to_a

# They consist of random digits and uppercase and lowercase letters, with the exception that the uppercase letter "O", uppercase letter "I", lowercase letter "l", and the number "0" are never used to prevent visual ambiguity. ( from: https://en.bitcoin.it/wiki/Address#What.27s_in_an_address )
EXCLUDED_CHARS = %w(l I 0 O) # ["l", "I", "O", "0"]

SIZES = [27, 34]

ALL_POSSIBLE_CHARS = ALPHABET_LOWER + ALPHABET_UPPER - EXCLUDED_CHARS

class PasswordGenerator < FXMainWindow
  def initialize(app)
    super(app, "Password generator", width: 400, height: 120)

    frame = FXHorizontalFrame.new self
    FXLabel.new frame, "Number of characters in password:"
    size_field = FXTextField.new frame, 4
    size_field.text = SIZES.first.to_s

    # hFrame2 = FXHorizontalFrame.new(self)
    # specialChrsCheck = FXCheckButton.new(hFrame2, "Include special characters in password")

    vframe = FXVerticalFrame.new self, opts: LAYOUT_FILL
    textArea = FXText.new vframe, opts: LAYOUT_FILL | TEXT_READONLY | TEXT_WORDWRAP

    hFrame3 = FXHorizontalFrame.new vframe
    generateButton = FXButton.new(hFrame3, "Generate")
    copyButton = FXButton.new(hFrame3, "Copy to clipboard")

    generateButton.connect(SEL_COMMAND) do
      textArea.removeText(0, textArea.length)
      textArea.appendText(generatePassword(size_field.text.to_i, ALL_POSSIBLE_CHARS))
    end
  end

  def generatePassword(pwLength, charArray)
    len = charArray.length
    pass = (1..pwLength).map do
      charArray[rand(len)]
    end.join
    spacePassword pass
  end

  def spacePassword(pass)
    pass.split("").each_slice(4).map{ |c| c.join }.join " "
  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

if __FILE__ == $0
  FXApp.new do |app|
    PasswordGenerator.new app
    app.create
    app.run
  end
end
