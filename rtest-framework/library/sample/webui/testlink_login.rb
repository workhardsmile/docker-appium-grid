module TestlinkLogin
  class LoginAccountInput < TextInput
    def initialize
      TextInput.new("id","login")
    end
  end
  
  class PasswordInput < TextInput
    def initialize
      TextInput.new("name","tl_password")
    end
  end
  
  class LoginButton < Button
    def initialize
      Button.new("name","login_submit")
    end
  end
end