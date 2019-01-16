(*
  Brook framework, Messages Unit

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookMessages;

{$i brook.inc}

interface

resourcestring
  { Default resource messages }
  { }
  SBrookDefaultLocale_rst = 'en-US';
  { Default resource error messages }
  { }
  SBrookInvalidRequestMethodError_rst = 'Invalid request method: %s';
  SBrookItemNotFoundError_rst = 'Item "%s" not found.';
  SBrookFileNotFoundError_rst = 'File not found: %s';
  SBrookNoRequestMethodError_rst = 'No REQUEST_METHOD passed from server.';
  SBrookNoApplicationRegisteredError_rst = 'No application registered.';
  SBrookApplicationAlreadyRegisteredError_rst = 'The application is already registered.';
  SBrookRegiterTBrookActionError_rst = 'Unable to register the type TBrookAction directly.';
  SBrookActionAlreadyRegisteredError_rst = 'The action "%s" is already registered.';
  SBrookDefaultActionAlreadyRegisteredError_rst = 'There is already a default action registered.';
  SBrookPatternAlreadyRegisteredError_rst = 'There is already an action registered with the pattern "%s".';
  SBrookRouterServiceAlreadyRegisteredError_rst = 'The router service is already registered.';
  SBrookNoRouterServiceRegisteredError_rst = 'No router service registered.';
  SBrookNoRouteRegisteredError_rst = 'No route registered.';
  SBrookCfgFileNotFoundError_rst = 'The config file was not found: "%s"';
  SBrookNotNilError_rst = '"%s" must not be nil.';
  SBrookEmptyLibraryNameError_rst = 'The library name must not be empty.';
  SBrookMethodNotAllowedError_rst = 'HTTP method not allowed for the requested resource.';
  SBrookConstraintAlreadyRegisteredError_rst = 'The constraint "%s" is already registered.';
  SBrookConstraintsServiceAlreadyRegisteredError_rst = 'The constraints service is already registered.';
  SBrookNoConstraintsServiceRegisteredError_rst = 'No constraints service registered.';
  SBrookNoLoggerServiceRegisteredError_rst = 'No logger service registered.';
  SBrookLoggerServiceAlreadyRegisteredError_rst = 'The logger service is already registered.';

var
  { Default messages }
  { }
  SBrookDefaultLocale: string = SBrookDefaultLocale_rst;
  { Default error messages }
  { }
  SBrookInvalidRequestMethodError: string = SBrookInvalidRequestMethodError_rst;
  SBrookItemNotFoundError: string = SBrookItemNotFoundError_rst;
  SBrookFileNotFoundError: string = SBrookFileNotFoundError_rst;
  SBrookNoRequestMethodError: string = SBrookNoRequestMethodError_rst;
  SBrookNoApplicationRegisteredError: string = SBrookNoApplicationRegisteredError_rst;
  SBrookApplicationAlreadyRegisteredError: string = SBrookApplicationAlreadyRegisteredError_rst;
  SBrookRegiterTBrookActionError: string = SBrookRegiterTBrookActionError_rst;
  SBrookActionAlreadyRegisteredError: string = SBrookActionAlreadyRegisteredError_rst;
  SBrookDefaultActionAlreadyRegisteredError: string = SBrookDefaultActionAlreadyRegisteredError_rst;
  SBrookPatternAlreadyRegisteredError: string = SBrookPatternAlreadyRegisteredError_rst;
  SBrookRouterServiceAlreadyRegisteredError: string = SBrookRouterServiceAlreadyRegisteredError_rst;
  SBrookNoRouterServiceRegisteredError: string = SBrookNoRouterServiceRegisteredError_rst;
  SBrookNoRouteRegisteredError: string = SBrookNoRouteRegisteredError_rst;
  SBrookCfgFileNotFoundError: string = SBrookCfgFileNotFoundError_rst;
  SBrookNotNilError: string = SBrookNotNilError_rst;
  SBrookEmptyLibraryNameError: string = SBrookEmptyLibraryNameError_rst;
  SBrookMethodNotAllowedError: string = SBrookMethodNotAllowedError_rst;
  SBrookConstraintAlreadyRegisteredError: string = SBrookConstraintAlreadyRegisteredError_rst;
  SBrookConstraintsServiceAlreadyRegisteredError: string = SBrookConstraintsServiceAlreadyRegisteredError_rst;
  SBrookNoConstraintsServiceRegisteredError: string = SBrookNoConstraintsServiceRegisteredError_rst;
  SBrookNoLoggerServiceRegisteredError: string = SBrookNoLoggerServiceRegisteredError_rst;
  SBrookLoggerServiceAlreadyRegisteredError: string = SBrookLoggerServiceAlreadyRegisteredError_rst;

implementation

end.
