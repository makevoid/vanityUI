require 'open3'

require 'fox16'
include Fox

PATH = File.expand_path "../", __FILE__

NUMBERS = (1..9).to_a
ALPHABET_LOWER = ("a".."z").to_a
ALPHABET_UPPER = ("A".."Z").to_a

# They consist of random digits and uppercase and lowercase letters, with the exception that the uppercase letter "O", uppercase letter "I", lowercase letter "l", and the number "0" are never used to prevent visual ambiguity. ( from: https://en.bitcoin.it/wiki/Address#What.27s_in_an_address )
EXCLUDED_CHARS = %w(l I 0 O) # ["l", "I", "O", "0"]

SIZES = [27, 34]

ALL_POSSIBLE_CHARS = ALPHABET_LOWER + ALPHABET_UPPER - EXCLUDED_CHARS

class Vanitygen

  # note: nickname refers to the vanity part of the public key

  attr_reader :nickname, :public_key, :private_key

  def initialize(nickname)
    @nickname = nickname
    out = generate_keypair
    parse_keypair out
  end

  private

  def vanitygen_cmd
    # bin = "vanitygen"
    bin = "vanitygen_osx"
    "#{PATH}/bin/vendor/#{bin} 1#{@nickname}  2>&1"
  end

  def generate_keypair
    cmd = vanitygen_cmd
    # puts cmd
    out = `#{cmd}`
    # puts out
    out
  end

  def generate_keypair
    stdin, stdout, stderr, @wait_thr = Open3.popen3 vanitygen_cmd

    @t = Thread.new {
      while true
        unless stderr.eof?
          line = stderr.readline
          puts line
        end
      end
    }
    ""
  end

  def parse_keypair(output)
    @public_key   = output.match(/Address: (\w+)/)[0]
    @private_key  = output.match(/Privkey: (\w+)/)[0]
  end

end


class PasswordGenerator < FXMainWindow
  def initialize(app)
    super(app, "Password generator", width: 400, height: 200)

    frame = FXHorizontalFrame.new self
    FXLabel.new frame, "Number of characters in password:"
    size_field = FXTextField.new frame, 4
    size_field.text = SIZES.first.to_s

    frame2 = FXHorizontalFrame.new self
    nick_field = FXTextField.new frame2, 4


    # hFrame2 = FXHorizontalFrame.new(self)
    # specialChrsCheck = FXCheckButton.new(hFrame2, "Include special characters in password")

    vframe = FXVerticalFrame.new self, opts: LAYOUT_FILL
    textArea = FXText.new vframe, opts: LAYOUT_FILL | TEXT_READONLY | TEXT_WORDWRAP

    hFrame3 = FXHorizontalFrame.new vframe
    generateButton = FXButton.new(hFrame3, "Generate")
    copyButton = FXButton.new(hFrame3, "Copy to clipboard")


    generateButton.connect(SEL_COMMAND) do
      vg = vanitygen(nick_field.text)
      textArea.removeText 0, textArea.length
      textArea.appendText vg.public_key
    end
  end

  def generate_password_ui(pwLength, charArray)
    pass = generate_password
    # spacePassword pass
  end

  def vanitygen(nick)
    @vanitygen = Vanitygen.new nick
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
