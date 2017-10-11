module TestlinkHome
  class AccountNameText < Text
    def initialize
      Text.new("xpath","//a[@href='logout.php']/../preceding-sibling::span[1]")
    end
  end
  
  class LogoutButton < Button
    def initialize
      Button.new("xpath","//a[@href='logout.php']")
    end
  end
end