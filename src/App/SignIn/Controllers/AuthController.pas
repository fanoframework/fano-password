(*!------------------------------------------------------------
 * [[APP_NAME]] ([[APP_URL]])
 *
 * @link      [[APP_REPOSITORY_URL]]
 * @copyright Copyright (c) [[COPYRIGHT_YEAR]] [[COPYRIGHT_HOLDER]]
 * @license   [[LICENSE_URL]] ([[LICENSE]])
 *------------------------------------------------------------- *)
unit AuthController;

interface

{$MODE OBJFPC}
{$H+}

uses

    fano;

type

    (*!-----------------------------------------------
     * controller that handle route :
     * POST /signin
     *
     * See Routes/SignIn/routes.inc
     *
     * @author [[AUTHOR_NAME]] <[[AUTHOR_EMAIL]]>
     *------------------------------------------------*)
    TAuthController = class(TController)
    private
        fSession : IReadOnlySessionManager;
        fPasswordHash : IPasswordHash;
        fTargetUrl : string;
    public
        constructor create(
            const viewInst : IView;
            const viewParamsInst : IViewParameters;
            const session : IReadOnlySessionManager;
            const passwHash : IPasswordHash;
            const targetUrl : string
        );

        destructor destroy(); override;

        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            const args : IRouteArgsReader
        ) : IResponse; override;
    end;

implementation

    constructor TAuthController.create(
        const viewInst : IView;
        const viewParamsInst : IViewParameters;
        const session : IReadOnlySessionManager;
        const passwHash : IPasswordHash;
        const targetUrl : string
    );
    begin
        inherited create(viewInst, viewParamsInst);
        fSession := session;
        fPasswordHash := passwHash;
        fTargetUrl := targetUrl;
    end;

    destructor TAuthController.destroy();
    begin
        fSession := nil;
        fPasswordHash := nil;
        inherited destroy();
    end;

    function TAuthController.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const args : IRouteArgsReader
    ) : IResponse;
    var username, password, targetUrl : string;
        hashedPassword : string;
        sess : ISession;
    begin
        sess := fSession.getSession(request);
        try
            sess.delete('userSignedIn');
            username := request.getParsedBodyParam('email');
            password := request.getParsedBodyParam('password');
            fPasswordHash.salt('hello@fano');
            hashedPassword := fPasswordHash.hash('world');
            if (username = 'hello@fano') and
                fPasswordHash.verify(password, hashedPassword) then
            begin
                sess.setVar('userSignedIn', 'true');
                targetUrl := request.getParsedBodyParam('targetUrl', fTargetUrl);
                result := TRedirectResponse.create(response.headers(), targetUrl);
            end else
            begin
                result := inherited handleRequest(request, response, args);
            end;
        finally
            sess := nil;
        end;
    end;

end.
