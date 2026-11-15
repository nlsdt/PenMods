
/**
 * Returns a number whose value is limited to the given range.
 *
 * @method Number.prototype.clamp
 * @param {Number} min The lower boundary
 * @param {Number} max The upper boundary
 * @return {Number} A number in the range (min, max)
 */
Number.prototype.clamp = function(min, max) {
    return Math.min(Math.max(this, min), max);
};

/**
 * Returns a number whose value is limited to the given range, bound same as clamp
 *
 * @method Number.prototype.bound
 * @param {Number} min The lower boundary
 * @param {Number} max The upper boundary
 * @return {Number} A number in the range (min, max)
 */
Number.prototype.bound = function(min, max) {
    return Math.min(Math.max(this, min), max);
};

/**
 * Returns a modulo value which is always positive.
 *
 * @method Number.prototype.mod
 * @param {Number} n The divisor
 * @return {Number} A modulo value
 */
Number.prototype.mod = function(n) {
    return ((this % n) + n) % n;
};

/**
 * Replaces %1, %2 and so on in the string to the arguments.
 *
 * @method String.prototype.format
 * @param {Any} ...args The objects to format
 * @return {String} A formatted string
 */
String.prototype.format = function() {
    var args = arguments;
    return this.replace(/%([0-9]+)/g, function(s, n) {
        return args[Number(n) - 1];
    });
};

/**
 * Makes a number string with leading zeros.
 *
 * @method String.prototype.padZero
 * @param {Number} length The length of the output string
 * @return {String} A string with leading zeros
 */
String.prototype.padZero = function(length){
    var s = this;
    while (s.length < length) {
        s = '0' + s;
    }
    return s;
};

/**
 * Makes a number string with leading zeros.
 *
 * @method Number.prototype.padZero
 * @param {Number} length The length of the output string
 * @return {String} A string with leading zeros
 */
Number.prototype.padZero = function(length){
    return String(this).padZero(length);
};

/**
 * Checks whether the string is a number.
 *
 * @method String.prototype.isNumber
 * @param {String} string The string to search for
 * @return {Boolean} True if the string is a number
 */
String.prototype.isNumber = function() {
    var reg = /^[0-9]*$/;
    return reg.test(this);
}

/**
 * Checks whether the string is chinese.
 *
 * @method String.prototype.isChinese
 * @param {String} string The string to search for
 * @return {Boolean} True if the string is chinese
 */
String.prototype.isChinese = function() {
    var reg = /[\u3220-\uFA29]+/;
    return reg.test(this);
}


/**
 * Checks whether the string contains a given string.
 *
 * @method String.prototype.contains
 * @param {String} string The string to search for
 * @return {Boolean} True if the string contains a given string
 */
String.prototype.contains = function(string) {
    return this.indexOf(string) >= 0;
};

/**
 * Generates a random integer in the range (0, max-1).
 *
 * @static
 * @method Math.randomInt
 * @param {Number} max The upper boundary (excluded)
 * @return {Number} A random integer
 */
Math.randomInt = function(max) {
    return Math.floor(max * Math.random());
};

// 去除首尾空格
String.prototype.trim = function()
{
    return this.replace(/(^\s*)|(\s*$)/g, "");
}

// 去除左侧空格
String.prototype.ltrim = function()
{
    return this.replace(/(^\s*)/g, "");
}

// 去除右侧空格
String.prototype.rtrim = function()
{
    return this.replace(/(\s*$)/g, "");
}

// 是否是 json
String.prototype.isJson = function()
{
    try {
        JSON.parse(this);
    } catch (e) {
        return false;
    }
    return true;
}

/**
 * Remove n chars from the end of the string
 *
 * @static
 * @method String.chop
 * @param {Number} n chars
 * @return {String} A string which remove n chars from the end
 */
String.prototype.chop = function(n)
{
    return this.slice(0, -n);
}

String.prototype.startsWith = function(prefix)
{
    return this.slice(0, prefix.length) === prefix
}

String.prototype.endsWith = function(suffix)
{
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
}

String.prototype.toLoadFileUrl = function()
{
    if (0 === this.length) {
        return ""
    }
    if (this.startsWith("qrc:/")) {
        return ("file://" + this.substring(4))
    }
    return this.startsWith("file:///") ? this : ("file://" + this)
}

String.prototype.urlToLocalFile = function()
{
    if (0 === this.length) {
        return ""
    }
    if (this.startsWith("qrc:/")) {
        return this.substring(4)
    }
    if (this.startsWith("file:///")) {
        return this.substring(7)
    }
    return this
}

/**
* The splice() method changes the content of a string by removing a range of
* characters and/or adding new characters.
*
* @this {String}
* @param {number} start Index at which to start changing the string.
* @param {number} delCount An integer indicating the number of old chars to remove.
* @param {string} newSubStr The String that is spliced in.
* @return {string} A new string with the spliced substring.
*/
String.prototype.splice = function(start, delCount, newSubStr) {
    return this.slice(0, start) + newSubStr + this.slice(start + Math.abs(delCount));
};

String.prototype.formatTouchreadingButtonName = function()
{
    if (3 >= this.length) {
        return this.toString()
    }
    return this.splice(2, 0, "\n")
}

String.prototype.replaceAll = function(search, replaceWith) {
    const searchRegExp = new RegExp(search, 'g');
    return this.replace(searchRegExp, replaceWith);
}

/**
 * Checks whether the two arrays are same.
 *
 * @method Array.prototype.equals
 * @param {Array} array The array to compare to
 * @return {Boolean} True if the two arrays are same
 */
Array.prototype.equals = function(array) {
    if (!array || this.length !== array.length) {
        return false;
    }
    for (var i = 0; i < this.length; i++) {
        if (this[i] instanceof Array && array[i] instanceof Array) {
            if (!this[i].equals(array[i])) {
                return false;
            }
        } else if (this[i] !== array[i]) {
            return false;
        }
    }
    return true;
}

/**
 * Makes a shallow copy of the array.
 *
 * @method Array.prototype.clone
 * @return {Array} A shallow copy of the array
 */
Array.prototype.clone = function() {
    return this.slice(0);
}

/**
 * Checks whether the array contains a given element.
 *
 * @method Array.prototype.contains
 * @param {Any} element The element to search for
 * @return {Boolean} True if the array contains a given element
 */
Array.prototype.contains = function(element) {
    return this.indexOf(element) >= 0;
}

String.prototype.replaceBetween = function(startIndex, endIndex, replacement) {
    return this.substring(0, startIndex) + replacement + this.substring(endIndex);
}
