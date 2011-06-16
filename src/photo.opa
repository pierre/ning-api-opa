/*
 * Copyright 2011 Ning, Inc.
 *
 * Ning licenses this file to you under the Apache License, version 2.0
 * (the "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at:
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */

package com.ning.api

import apis.oauth

/**
 * API Configuration object
 *
 * @see http://developer.ning.com/docs/ningapi/1.0/overview/authentication.html
 */
type NingAPI.config = {
    consumer: {
        key: string
        secret: string
    }

    token: {
        token: string
        secret: string
    }

    subdomain: string
}

/**
 * Ning content attributes
 */
type NingAPI.author_properties = {
    fullName: string /** [Read only] The full name of the author **/
    iconUrl: string  /** [Read only] The author's profile photo **/
    url: string      /** [Read only] The author's profile page on the Ning Network **/
}

type NingAPI.photo_properties = {
    id: string                        /** [Read only]The unique ID for a photo **/
    author: NingAPI.author_properties /** [Read only] The screen name of the member who created the photo **/
    createdDate: string               /** [Read only] The timestamp from the creation date **/
    updatedDate: string               /** [Read only] The timestamp from the last modification **/
    title: string                     /** [Read/Write] The title of the photo **/
    description: string               /** [Read/Write] The content of the photo **/
    visibility: string                /** [Read/Write] Can friends see or all members see the photo? **/
    approved: bool                    /** [Read/Write] True if the administrator has approved the photo **/
    commentCount: int                 /** [Read only] The number of comments on the photo **/
    url: string                       /** [Read only] URL of the photo's detail page **/
    tags: string                      /** [Read only] A JSON array of tags: { "food", "apple" } **/
}

/**
 * Ning API parameters
 */
type NingAPI.photos_query_parameters = {
    author: string /** Retrieve photos for a specific user **/
    private: bool  /** If true, only retrieve private photos. If you are not the Network Creator, using this
                       parameter will result in a 403 Forbidden error. **/
    approved: bool /** If true, only retrieve approved photos **/
    fields: string /** Comma-separated list of desired properties, this is only a hint to the server **/
    anchor: string /** An opaque token encodes the page of results returned, used in conjunction with count to page through a result set **/
    count: int     /** Returns one photo by default and supports a maximum of 100. Also supports negative values down to -100 for
                       retrieving photos before the anchor. **/
}

NingAPI =
{{

    /**
     * {1 Public functions}
     */

    /**
     * Retrieve a specific photo or a specific set of photos, up to 100
     *
     * @param config NingAPI config object
     * @param ids csv of Photo ids
     * @param fields fields to fetch
     */
    get_photos_by_id(config: NingAPI.config, ids: string, params: NingAPI.photos_query_parameters) =
        (parameters, url) = _configure(config, "Photo")
        OAuth(parameters).get_protected_resource(url, [("id", ids)], config.token.token, config.token.secret)

    /**
     * Retrieve specific photos
     *
     * @param config NingAPI config object
     * @param attributes NingAPI.photo_properties
     */
    get_recent_photos(config: NingAPI.config, params: NingAPI.photos_query_parameters): string =
        (parameters, url) = _configure(config, "Photo/recent")
        OAuth(parameters).get_protected_resource(url, [], config.token.token, config.token.secret)

    /**
     * Retrieve the number of photos created after the given date
     *
     * @param config NingAPI config object
     * @param createdAfter The ISO-8601 date to start counting after. If the date is more than a week old, a 400 response will be returned
     * @param attributes NingAPI.photo_properties
     */
    get_photos_count(config: NingAPI.config, createdAfter: string, params: NingAPI.photos_query_parameters): string =
        (parameters, url) = _configure(config, "Photo/count")
        OAuth(parameters).get_protected_resource(url, [("createdAfter", createdAfter)], config.token.token, config.token.secret)


    /**
     * {1 Private implementation}
     */

    _configure(config: NingAPI.config, resource: string): (OAuth.parameters, string) =
        url = String_concat(["https://external.ningapis.com/xn/rest/", config.subdomain, "/1.0/", resource])
        parameters = {
             consumer_key = config.consumer.key
            ;consumer_secret = config.consumer.secret
            ;auth_method = {PLAINTEXT} : OAuth.signature_type
            ;request_token_uri = url
            ;access_token_uri = url
            ;authorize_uri = url
            ;http_method = {GET} : OAuth.method
            ;inlined_auth = false
        }
        (parameters, url)
}}
