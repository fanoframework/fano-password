(*!------------------------------------------------------------
 * My App ([[APP_URL]])
 *
 * @link      [[APP_REPOSITORY_URL]]
 * @copyright Copyright (c) [[COPYRIGHT_YEAR]] [[COPYRIGHT_HOLDER]]
 * @license   [[LICENSE_URL]] ([[LICENSE]])
 *------------------------------------------------------------- *)
unit bootstrap;

interface

uses

    fano;

type

    TAppServiceProvider = class(TDaemonAppServiceProvider)
    protected
        function buildAppConfig(const container : IDependencyContainer) : IAppConfiguration; override;
        function buildDispatcher(
            const container : IDependencyContainer;
            const routeMatcher : IRouteMatcher;
            const config : IAppConfiguration
        ) : IDispatcher; override;

    public
        procedure register(const container : IDependencyContainer); override;
    end;

    TAppRoutes = class(TRouteBuilder)
    public
        procedure buildRoutes(
            const container : IDependencyContainer;
            const router : IRouter
        ); override;
    end;

implementation

uses
    sysutils

    (*! -------------------------------
     *   controllers factory
     *----------------------------------- *)
    {---- put your controller factory here ---};


    function TAppServiceProvider.buildAppConfig(const container : IDependencyContainer) : IAppConfiguration;
    begin
        container.add(
            'config',
            TJsonFileConfigFactory.create(
                getCurrentDir() + '/config/config.json'
            )
        );
        result := container['config'] as IAppConfiguration;

    end;
    function TAppServiceProvider.buildDispatcher(
        const container : IDependencyContainer;
        const routeMatcher : IRouteMatcher;
        const config : IAppConfiguration
    ) : IDispatcher;
    begin
        container.add('appMiddlewares', TMiddlewareListFactory.create());

        container.add(
            'sessionManager',
            TJsonFileSessionManagerFactory.create(
                config.getString('session.name'),
                config.getString('session.dir')
            )
        );

        container.add(
            GuidToString(IDispatcher),
            TSessionDispatcherFactory.create(
                container['appMiddlewares'] as IMiddlewareLinkList,
                routeMatcher,
                TRequestResponseFactory.create(),
                container['sessionManager'] as ISessionManager,
                (TCookieFactory.create()).domain(
                    config.getString('cookie.domain')
                ),
                config.getInt('cookie.maxAge')
            )
        );
        result := container[GuidToString(IDispatcher)] as IDispatcher;
    end;

    procedure TAppServiceProvider.register(const container : IDependencyContainer);
    begin
        {$INCLUDE Dependencies/dependencies.inc}
    end;

    procedure TAppRoutes.buildRoutes(
        const container : IDependencyContainer;
        const router : IRouter
    );
    begin
        {$INCLUDE Routes/routes.inc}
    end;
end.