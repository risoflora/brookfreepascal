# INTRODUCTION

**Brook for Free Pascal** is the perfect [Free Pascal](http://freepascal.org/) framework for your web applications. It's pure Pascal. You don't need to leave your preferred programming language.

It's complete: simple actions or configurable actions for database access, advanced routing features, wizard for [Lazarus](http://lazarus.freepascal.org), support for internationalization, high compatibility with [JSON](http://json.org) structures, easy and elegant [REST](http://en.wikipedia.org/wiki/Representational_state_transfer) implementation, plugins for varied needs, extensible and decoupled brokers... In fact, you have several reasons to adopt Brook as your web development framework.

## FEATURES

* **Advanced routes management** – Actions are performed by means of routes. Brook knows how to receive a request and choose the correct URL and the correct method to reply to it.
* **Integrated data persistance** – Brook offers a table object where data can be handled. Less instantiations, less coding, with an elegant syntax.
* **JSON native support** – [JSON](http://json.org) is widespred in the web for data exchange purposes. You will really appreciate Brooks' good JSON support.
* **REST architecture support** – [REST](http://en.wikipedia.org/wiki/Representational_state_transfer) is an architecture able to simplify and standardize data requests and replies. Brook is powerful even if you don't use REST – but you will want to use it.
* **Lazarus wizards for installation and usage** - With [Lazarus](http://www.lazarus.freepascal.org), development is easier; with the Brook wizards, only a few clicks are required to start and configure your Brook projects.

## GET STARTED

### If you use Free Pascal only

Create three files:

* `cgi1.lpr`;
* `unit1.pas`;
* `brokers.pas`;

In `cgi1.lpr`, type:

```pascal
program cgi1;
 
{$mode objfpc}{$H+}
 
uses
  BrookApplication, Brokers, Unit1;
 
begin
  BrookApp.Run;
end.
```

In `unit1.pas`, type:

```pascal
unit Unit1;
 
{$mode objfpc}{$H+}
 
interface
 
uses
  BrookAction;
 
type
  TMyAction = class(TBrookAction)
  public
    procedure Get; override;
  end;
 
implementation
 
procedure TMyAction.Get;
begin
  Write('Hello world!');
end;
 
initialization
  TMyAction.Register('*');
 
end.
```

In `brokers.pas`, type:

```pascal
unit Brokers;

{$mode objfpc}{$H+}

interface

uses
  BrookFCLCGIBroker;

implementation

end. 
```

Compile the project `cgi1.lpr` and copy the resulting file to CGI directory of your web server. Now, in your web browser, access the following URL:

`http://localhost/cgi-bin/cgi1`

***

### If you are a Lazarus user

Open and install the file `brookex.lpk`. After the installation, select _File | New ..._ and, in _Brook for Free Pascal_, choose the _Simple CGI application_ option as shown in the figure below:

![Brook - New project](https://user-images.githubusercontent.com/1456829/51649575-cd69d800-1f63-11e9-878d-5191b74faf77.png)

Save and compile the project. Copy the resulting file to the CGI directory of your web server and enjoy! See the final result:

![Brook - Hello world](https://user-images.githubusercontent.com/1456829/51649574-cd69d800-1f63-11e9-83ed-111a7cd19d79.png)

## PLUGINS

* **[dOPF](https://github.com/risoflora/brookfreepascal/tree/main/plugins/dopf)** – Sleek, intuitive and fast object persistence for faster and easier database development.
* **[RUtils](https://github.com/risoflora/brookfreepascal/tree/main/plugins/rutils)** – Some general purpose routines for string conversion, parsing, encoding and more.
* **[JTemplate](https://github.com/risoflora/brookfreepascal/tree/master/plugins/jtemplate)** – Fill variables in a template file.
* **[QTemplate](https://github.com/leledumbo/QTemplate)** – Alternative to the FPTemplate engine.
* **[EasyRSS](https://github.com/risoflora/brookfreepascal/tree/master/plugins/easyrss)** – Easiest way for Pascal developers to provide news updating services in their applications.
* **[XMailer](https://github.com/risoflora/brookfreepascal/tree/master/plugins/xmailer)** – Simple way to send e-mail using Free Pascal.
* **[AlgEx](https://github.com/risoflora/brookfreepascal/tree/master/plugins/algex)** – Process algebraic expressions passed as strings.
* **[Captcha](https://github.com/risoflora/brookfreepascal/tree/master/plugins/captcha)** – Verification images to block bot access on login pages.
* **[MGeoIP](https://github.com/risoflora/brookfreepascal/tree/master/plugins/mgeoip)** – Identify the name of the country or city where IPs reside.
* **[ConvUtils](https://github.com/risoflora/brookfreepascal/tree/master/plugins/convutils)** – Conversion between units of measurement (centimeters, inches, liters etc.).
* **[HtmlDoc](https://github.com/risoflora/brookfreepascal/tree/master/plugins/htmldoc)** – Write headers, body and other relevant tags using Object Pascal.
* **[LJGridUtils](https://github.com/risoflora/brookfreepascal/tree/master/plugins/ljgridutils)** – Easy conversion from LCL to JSON and vice versa.
* **[Brook-Telegram](https://github.com/Al-Muhandis/brook-telegram)** – Consume the Telegram Bots API in a Brook application.

## LICENSE

The source code of the Brook for Free Pascal is distributed under the GNU Lesser General Public License. See the [project licence](https://github.com/risoflora/brookfreepascal/blob/master/LICENSE.txt) for copyright/license details.

## SYSTEM REQUIREMENTS

The stable version of [Free Pascal & Lazarus](https://sourceforge.net/projects/lazarus/).

## DOCUMENTATION

The project documentation is available in two formats: [HTML](https://risoflora.github.io/brookfreepascal-docs/index.html) and [PDF](https://risoflora.github.io/brookfreepascal-docs/Brook%20for%20Free%20Pascal.pdf).

## VERSIONING

For transparency and insight into our release cycle, and for striving to maintain backward compatibility, Brook for Free Pascal will be maintained under the Semantic Versioning guidelines as much as possible.

Releases will be numbered with the following format:

`<major>.<minor>.<release>`

And constructed with the following guidelines:

* Breaking backward compatibility bumps the major (and resets the minor and release);
* New additions without breaking backward compatibility bumps the minor (and resets the release);
* Bug fixes and misc changes bumps the release;

For more information on SemVer, please visit [http://semver.org](http://semver.org).

## SUPPORT, BUGS, CONTACT

Please use the [issues page](https://github.com/risoflora/brookfreepascal/issues). Your cooperation will be appreciated.

## CONTRIBUTORS

Brook would not be possible without important and active contributors. See their names [here](https://github.com/risoflora/brookfreepascal/blob/master/CONTRIBUTORS.txt).

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=GE9VT768TLP74&lc=GB&item_name=Brook%20for%20Free%20Pascal&item_number=brookfreepascal&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted">
  <img src="https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif">
</a>

See the name of all donors [here](https://github.com/risoflora/brookfreepascal/blob/master/DONORS.txt).

## DOWNLOAD

You can download the last release [here](https://github.com/risoflora/brookfreepascal/releases). Alternatively, you can also follow the project's GIT repository. The address is:

`https://github.com/risoflora/brookfreepascal.git`

## THIRD PARTY

The Brook supports third party solutions and, for these, there is a broker file implementing your features. You can download the package containing all files [here](https://github.com/silvioprog/brookframework/releases/download/v3.0.0/third-party.zip).

## ALTERNATIVES

* [Brook framework](https://github.com/risoflora/brookframework) - Microframework which helps to develop web Pascal applications.
* [mORMot](https://github.com/synopse/mORMot) - Synopse mORMot ORM/SOA/MVC framework.
* [Free Spider](https://github.com/motaz/freespider) - Web development package for Free Pascal/Lazarus.
* [FCL-Web](http://wiki.freepascal.org/fcl-web) - Built-in Free Pascal web library.

## Welcome to Brook! ![Welcome to Brook!](http://l.yimg.com/us.yimg.com/i/mesg/emoticons7/113.gif)