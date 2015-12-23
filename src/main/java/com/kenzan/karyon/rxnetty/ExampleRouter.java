/**
 * Copyright 2015 Kenzan, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.kenzan.karyon.rxnetty;

import io.netty.buffer.ByteBuf;
import io.reactivex.netty.protocol.http.server.HttpServerRequest;
import io.reactivex.netty.protocol.http.server.HttpServerResponse;
import io.reactivex.netty.protocol.http.server.RequestHandler;
import netflix.karyon.transport.http.SimpleUriRouter;
import netflix.karyon.transport.http.health.HealthCheckEndpoint;
import rx.Observable;

import com.kenzan.karyon.rxnetty.health.HealthCheck;
import com.kenzan.karyon.rxnetty.resource.HelloResource;
import com.kenzan.karyon.rxnetty.resource.IndexResource;


public class ExampleRouter implements RequestHandler<ByteBuf, ByteBuf>{

    private final SimpleUriRouter<ByteBuf, ByteBuf> delegate;

    public ExampleRouter() {
        delegate = new SimpleUriRouter<>();
        HealthCheck healthCheckHandler = new HealthCheck();

        delegate
        .addUri("", new IndexResource())
        .addUri("/hello/*", new HelloResource())
        .addUri("/healthcheck", new HealthCheckEndpoint(healthCheckHandler));
    }

    @Override
    public Observable<Void> handle(HttpServerRequest<ByteBuf> request,
            HttpServerResponse<ByteBuf> response) {
        return delegate.handle(request, response);
    }

}
