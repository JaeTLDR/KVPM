param(
    $keyvaultname = "spectrekv",
    $keyvaultprefix = "sdepw-"
)

#libs
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
import-module azurerm

#script variables
$build = "0.1"
$imgpath = $(pwd).path + "\KVPM.png"

#functions
function login {
    $loginbtn.Enabled = $false
    if ($(Get-AzureRmContext).account){
        showform
        return
    }
    try{
        Login-AzureRmAccount
        showform
        $loginbtn.Enabled = $true
    }
    catch{
        $Popup = new-object -comobject wscript.shell
        $Popup.popup("login failed",0,"ERROR!",16)|Out-Null
        $loginbtn.Enabled =$true
    }
    
}

function logout {
    Set-AzureRmContext -Context ([Microsoft.Azure.Commands.Profile.Models.PSAzureContext]::new())
    clearsecret
    hideform
}

function showform {
    retrievesecrets
    $MainPanel.SelectedIndex=1
}

function hideform {
    $loginbtn.Enabled =$true
    $MainPanel.SelectedIndex=0
}

function retrievesecrets {
    $skeys = (Get-AzureKeyVaultSecret –VaultName "$keyvaultname" |Where-Object {$_.name -like "$keyvaultprefix*"}).name
    ForEach ($key in $skeys) {
        [void] $DropDown.Items.Add($key)
    }
}

function getsecretvalue {
    $getsecretbtn.enabled = $false
    if (($dropdown.text -notin $dropdown.Items)-or ($dropdown.text -eq "select")){
        $secrettxt.text = ""
        $Popup = new-object -comobject wscript.shell
        $Popup.popup("Key must be selected",0,"ERROR!",16)|Out-Null
    } else {
        $secrettxt.text = (Get-AzureKeyVaultSecret –VaultName "$keyvaultname" -Name $($dropdown.text)).SecretValueText
    }
    $getsecretbtn.enabled = $true
}

function copytoclip{
    $secrettxt.text |clip.exe
}

function clearsecret{
    $secrettxt.text = ""
}

function About {
    # About Form Objects
    $aboutForm          = New-Object System.Windows.Forms.Form
    $aboutFormExit      = New-Object System.Windows.Forms.Button
    $aboutFormImage     = New-Object System.Windows.Forms.PictureBox
    $aboutFormNameLabel = New-Object System.Windows.Forms.Label
    $aboutFormText      = New-Object System.Windows.Forms.Label

    # About Form
    $aboutForm.AcceptButton  = $aboutFormExit
    $aboutForm.CancelButton  = $aboutFormExit
    $aboutForm.ClientSize    = "350, 120"
    $aboutForm.ControlBox    = $false
    $aboutForm.ShowInTaskBar = $false
    $aboutForm.FormBorderStyle = 1
    # $aboutForm.FormBorderStyle = "fixeddialog"
    $aboutForm.MaximizeBox = $false
    $aboutForm.MinimizeBox = $false
    $aboutForm.StartPosition = "CenterParent"
    $aboutForm.Text          = "About KVPM"
    $aboutForm.Add_Load($aboutForm_Load)

    # About PictureBox
    $aboutFormImage.ImageLocation = $imgpath
    $aboutFormImage.Location = "5, 5"
    $aboutFormImage.Size     = "72, 72"
    $aboutFormImage.SizeMode = "StretchImage"
    $aboutForm.Controls.Add($aboutFormImage)

    # About Name Label
    $aboutFormNameLabel.Font     = New-Object Drawing.Font("Microsoft Sans Serif", 9, [System.Drawing.FontStyle]::Bold)
    $aboutFormNameLabel.Location = "130, 20"
    $aboutFormNameLabel.Size     = "200, 18"
    $aboutFormNameLabel.Text     = "KeyVault Password Manager $build"
    $aboutForm.Controls.Add($aboutFormNameLabel)

    # About Text Label
    $aboutFormText.Location = "130, 40"
    $aboutFormText.Size     = "300, 20"
    $aboutFormText.Text     = "by JaeTLDR"
    $aboutForm.Controls.Add($aboutFormText)

    $aboutlink=new-object System.Windows.Forms.LinkLabel
    $aboutlink.add_click({start-process "https://github.com/JaeTLDR/KVPM/issues"})
    $aboutlink.Size     = "200, 20"
    $aboutlink.Location = "130,65"
    $aboutlink.Text     = "Suggestions? "
    $aboutForm.Controls.Add($aboutlink)
    
    $licenselink=new-object System.Windows.Forms.LinkLabel
    $licenselink.add_click({start-process "http://www.apache.org/licenses/LICENSE-2.0"})
    $licenselink.Size     = "100, 20"
    $licenselink.Location = "130,85"
    $licenselink.Text     = "License"
    $aboutForm.Controls.Add($licenselink)
    # About Exit Button
    $aboutFormExit.Location = "10, 80"
    $aboutFormExit.Text     = "OK"
    $aboutForm.Controls.Add($aboutFormExit)

    [void]$aboutForm.ShowDialog()
}

#mainform
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Height = 500
$mainForm.MainMenuStrip = $menuMain
$mainForm.Width = 400
$mainForm.StartPosition = "CenterScreen"
$mainForm.Text = "KVPM-$build"
$mainForm.MinimumSize = "400,500"
$mainForm.MaximizeBox = $false
$mainForm.MinimizeBox = $false
$mainForm.FormBorderStyle = 1
$mainForm.StartPosition = "CenterParent"

$MainPanel = new-object System.Windows.Forms.TabControl
$mainpanel.Dock = "fill"
$mainpanel.Appearance = "buttons"
$MainPanel.SizeMode = "fixed"
$MainPanel.ItemSize = "0,1"
$mainForm.Controls.Add($MainPanel)

$logintab = new-object System.Windows.Forms.TabPage
$mainPanel.Controls.Add($logintab)

$PMtab = new-object System.Windows.Forms.TabPage
$mainPanel.Controls.Add($PMtab)

#login tab  
$loginimg = New-Object System.Windows.Forms.PictureBox
$loginimg.ImageLocation = $imgpath
$loginimg.Location = "125, 37"
$loginimg.Size = "150, 150"
$loginimg.SizeMode = "StretchImage"
$logintab.Controls.Add($loginimg)

$loginbtn=new-object System.Windows.Forms.Button
$loginbtn.location="100,225"
$loginbtn.Size="200,50"
$loginbtn.text="Login"
$loginbtn.add_click({login})
$logintab.Controls.Add($loginbtn)

$aboutlink = new-object System.Windows.Forms.LinkLabel
$aboutlink.Location ="100,420"
$aboutlink.Size ="200,20"
$aboutlink.Text ="About.."
$aboutlink.TextAlign ="MiddleCenter" 
$aboutlink.add_click({about})
$logintab.Controls.Add($aboutlink)
#pmtab
$pmmgrimg     = New-Object System.Windows.Forms.PictureBox
$pmmgrimg.ImageLocation = $imgpath
$pmmgrimg.Location = "125, 37"
$pmmgrimg.Size     = "150, 150"
$pmmgrimg.SizeMode = "StretchImage"
$pmtab.Controls.Add($pmmgrimg)

$logoutbtn=new-object System.Windows.Forms.Button
$logoutbtn.location="295,0"
$logoutbtn.Size="80,25"
$logoutbtn.text="logout"
$logoutbtn.add_click({logout})
$pmtab.Controls.Add($logoutbtn)

$secretlabel = new-object System.Windows.Forms.Label
$secretlabel.location = "100,240"
$secretlabel.size = "200,20"
$secretlabel.Text = "Select secret"
$secretlabel.TextAlign ="MiddleCenter" 
$pmtab.Controls.Add($secretlabel)

$DropDown = new-object System.Windows.Forms.ComboBox
$DropDown.Location = new-object System.Drawing.Size(100,270)
$DropDown.Size = new-object System.Drawing.Size(200,25)
[void] $DropDown.Items.Add("select")
$DropDown.SelectedIndex = 0
$DropDown.add_SelectedIndexChanged({clearsecret})
$DropDown.DropDownStyle = "DropDownList"
$pmtab.Controls.Add($DropDown)

$secrettxt = New-Object System.Windows.Forms.TextBox
$secrettxt.location = "100,305"
$secrettxt.Size = "200,25"
$secrettxt.text = ""
$secrettxt.Enabled = $false
$secrettxt.PasswordChar = "*"
$pmtab.Controls.Add($secrettxt)

$clipbtn=new-object System.Windows.Forms.Button
$clipbtn.location = "100,335"
$clipbtn.Size = "200,25"
$clipbtn.text = "Copy to clipboard"
$clipbtn.add_click({copytoclip})
$pmtab.Controls.Add($clipbtn)

$getsecretbtn=new-object System.Windows.Forms.Button
$getsecretbtn.location = "100,365"
$getsecretbtn.Size = "200,25"
$getsecretbtn.text = "get secret"
$getsecretbtn.add_click({getsecretvalue})
$pmtab.Controls.Add($getsecretbtn)

$aboutlinkpm = new-object System.Windows.Forms.LinkLabel
$aboutlinkpm.Location ="100,420"
$aboutlinkpm.Size ="200,20"
$aboutlinkpm.Text ="About.."
$aboutlinkpm.TextAlign ="MiddleCenter" 
$aboutlinkpm.add_click({about})
$PMtab.Controls.Add($aboutlinkpm)

$mainForm.ShowDialog()